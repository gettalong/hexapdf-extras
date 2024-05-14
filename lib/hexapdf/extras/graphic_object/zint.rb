# frozen_string_literal: true

require 'zint'

module HexaPDF
  module Extras
    module GraphicObject

      # Generates a barcode using the {ruby-zint}[https://github.com/eliasfroehner/ruby-zint]
      # library that uses the libzint barcode generation library.
      #
      # It implements the {HexaPDF graphic object
      # interface}[https://hexapdf.gettalong.org/documentation/api/HexaPDF/Content/GraphicObject/index.html]
      # and can therefore easily be used via the +:barcode+ name:
      #
      #   canvas.draw(:barcode, width: 50, at: [10, 40], value: 'Hello!', symbology: :code128)
      #
      # Except for a few keyword arguments all are passed through to ruby-zint, so everything that
      # is supported by Zint::Barcode can be used. To make specifying symbologies easier, it is
      # possible to use symbolic names instead of the constants, see #configure.
      #
      # == Examples
      #
      # * Linear barcode
      #
      #     #>pdf-canvas100
      #     canvas.draw(:barcode, width: 60, at: [20, 45], value: '1123456', symbology: :upce)
      #     canvas.draw(:barcode, width: 60, at: [20, 5], value: 'Hello!', symbology: :code128)
      #
      # * Stacked barcode
      #
      #     #>pdf-canvas100
      #     canvas.draw(:barcode, width: 80, at: [10, 40], symbology: :codablockf,
      #                 value: 'Hello HexaPDF!', option_1: 3)
      #
      # * Composite barcode
      #
      #     #>pdf-canvas100
      #     canvas.draw(:barcode, width: 80, at: [10, 20], symbology: :gs1_128_cc,
      #                 value: '[99]1234-abcd', primary: "[01]03312345678903", option_1: 3)
      #
      # * 2D barcode
      #
      #     #>pdf-canvas100
      #     canvas.draw(:barcode, width: 80, at: [10, 10], symbology: :datamatrix,
      #                 value: 'Hello HexaPDF!', option_3: 100, output_options: 0x0100)
      class Zint

        # Creates and configures a new Zint drawing support object.
        #
        # See #configure for the allowed keyword arguments.
        def self.configure(**kwargs)
          new.configure(**kwargs)
        end

        # The position of the bottom-left corner of the barcode.
        #
        # Default: [0, 0].
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:barcode, height: 50, value: 'test', symbology: :code128)
        #   canvas.draw(:barcode, height: 50, value: 'test', symbology: :code128, at: [20, 50])
        attr_accessor :at

        # The width of resulting barcode.
        #
        # The resulting size of the barcode depends on whether width and #height are set:
        #
        # * If neither width nor height are set, the barcode uses the size returned by ruby-zint.
        #
        # * If both are set, the barcode is fit exactly into the given rectangle.
        #
        # * If either width or height is set, the other dimension is based on the set dimension so
        #   that the original aspect ratio is maintained.
        #
        # Default: nil.
        #
        # Examples:
        #
        # * No dimension set
        #
        #     #>pdf-canvas100
        #     canvas.draw(:barcode, value: 'test', symbology: :code128)
        #
        # * One dimension set
        #
        #     #>pdf-canvas100
        #     canvas.draw(:barcode, width: 60, value: 'test', symbology: :code128)
        #     canvas.draw(:barcode, height: 50, value: 'test', symbology: :code128, at: [0, 50])
        #
        # * Both dimensions set
        #
        #     #>pdf-canvas100
        #     canvas.draw(:barcode, width: 60, height: 60, value: 'test', symbology: :code128)
        attr_accessor :width

        # The height of the barcode.
        #
        # For details and examples see #width.
        #
        # Default: nil.
        attr_accessor :height

        # The font used when outputting strings.
        #
        # Any font that is supported by the HexaPDF::Document::Layout module is supported.
        #
        # Default: 'Helvetica'.
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:barcode, height: 50, font: 'Courier', value: 'test', symbology: :code128)
        attr_accessor :font

        # The keyword arguments that are passed on to Zint::Barcode.new.
        #
        # Default: {}.
        attr_accessor :zint_kws

        # Creates a Zint graphic object.
        def initialize
          @at = [0, 0]
          @width = nil
          @height = nil
          @font = 'Helvetica'
          @zint_kws = {}
        end

        # Configures the Zint graphic object and returns self.
        #
        # The following arguments are allowed:
        #
        # :at::
        #     The position of the bottom-left corner (see #at).
        #
        # :width::
        #     The width of the barcode (see #width).
        #
        # :height::
        #     The height of the barcode (see #height).
        #
        # :font::
        #     The font to use when outputting strings (see #font).
        #
        # :symbology::
        #     The type of barcode. Supports using symbols instead of constants, e.g. +:code128+
        #     instead of Zint::BARCODE_CODE128.
        #
        # :zint_kws::
        #     Keyword arguments that are passed on to ruby-zint.
        #
        # Any arguments not specified are not modified and retain their old value, see the attribute
        # methods for the inital default values.
        def configure(at: nil, width: nil, height: nil, font: nil, symbology: nil, **zint_kws)
          @at = at if at
          @width = width if width
          @height = height if height
          @font = font if font
          @zint_kws = zint_kws unless zint_kws.empty?
          @zint_kws[:symbology] = if symbology && symbology.kind_of?(Symbol)
                                    ::Zint.const_get("BARCODE_#{symbology.upcase}")
                                  elsif symbology
                                    symbology
                                  end
          self
        end

        # Maps the Zint color codes to HexaPDF color names.
        COLOR_CODES = {
          1 => "cyan",
          2 => "blue",
          3 => "magenta",
          4 => "red",
          5 => "yellow",
          6 => "green",
          7 => "black",
          8 => "white",
        }

        # Draws the Zint::Barcode object onto the given canvas, with the bottom-left corner at the
        # position specified by #at and the size specified by #width and #height.
        def draw(canvas)
          barcode = ::Zint::Barcode.new(**@zint_kws)
          vector = barcode.to_vector

          height = vector.height
          form = canvas.form(vector.width, height) do |form_canvas|
            form_canvas.fill_color(barcode.bgcolour).rectangle(0, 0, vector.width, height).fill
            vector.each_rectangle.group_by {|rect| rect.colour }.each do |color, rects|
              form_canvas.fill_color(COLOR_CODES.fetch(color, barcode.fgcolour))
              rects.each {|rect| form_canvas.rectangle(rect.x, height - rect.y, rect.width, -rect.height) }
              form_canvas.fill
            end
            vector.each_circle.group_by {|circle| circle.colour }.each do |color, circles|
              form_canvas.fill_color(COLOR_CODES.fetch(color, barcode.fgcolour))
              circles.each {|circle| form_canvas.circle(circle.x, height - circle.y, circle.diameter / 2.0) }
              form_canvas.fill
            end
            layout = canvas.context.document.layout
            vector.each_string do |string|
              fragment = layout.text_fragments(string.text, font: @font, font_size: string.fsize)[0]
              x = string.x + case string.halign
                             when 0 then -fragment.width / 2.0
                             when 1 then 0
                             when 2 then -fragment.width
                             end
              fragment.draw(form_canvas, x, height - string.y)
            end
          end

          canvas.xobject(form, at: @at, width: @width, height: @height)
        end
      end

    end
  end
end
