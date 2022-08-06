# frozen_string_literal: true

require 'rqrcode_core'

module HexaPDF
  module Extras
    module GraphicObject

      # Generates a QR code and renders it using simple PDF canvas graphics.
      #
      # It implements the {HexaPDF graphic object
      # interface}[https://hexapdf.gettalong.org/documentation/reference/api/HexaPDF/Content/GraphicObject/index.html]
      # and can therefore easily be used via the +:qrcode+ name:
      #
      #   #>pdf-canvas100
      #   canvas.draw(:qrcode, data: 'hello', size: 100)
      #
      # This class relies on {rqrcode_core}[https://github.com/whomwah/rqrcode_core/] to generate
      # the QR code from the given data. All options of rqrcode_core are supported, have a look at
      # their documentation to see the allowed values.
      class QRCode

        # Creates and configures a new QRCode drawing support object.
        #
        # See #configure for the allowed keyword arguments.
        def self.configure(**kwargs)
          new.configure(**kwargs)
        end

        # The position of the bottom-left corner of the QR code.
        #
        # Default: [0, 0].
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 'test', size: 30)
        #   canvas.draw(:qrcode, data: 'test', size: 20, at: [50, 50])
        attr_accessor :at

        # The size of the whole rendered QR code.
        #
        # Default: none
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 'test', size: 80, at: [10, 10])
        attr_accessor :size

        # The color for the dark QR code modules ('pixels')
        #
        # Default: 'black'.
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 'test', size: 100, dark_color: 'green')
        attr_accessor :dark_color

        # The color for the light QR code modules ('pixels').
        #
        # Default: none (i.e. they are not drawn).
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 'test', size: 100, light_color: 'yellow')
        attr_accessor :light_color

        # The data for which the QR code should be generated.
        #
        # This is directly passed to rqrcode_core as the +data+ argument.
        #
        # Default: none
        attr_accessor :data

        # The code size of the the QR code (normally called 'version').
        #
        # This is directly passed to rqrcode_core as the +size+ argument.
        #
        # Default: nil (i.e. let rqrcode_core decide)
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 'test', size: 100, code_size: 10)
        attr_accessor :code_size

        # The maximum code size of the QR code.
        #
        # This is directly passed to rqrcode_core as the +max_size+ argument.
        #
        # Default: nil (i.e. let rqrcode_core decide)
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 't'*100, size: 100, max_code_size: 10)
        attr_accessor :max_code_size

        # The error correction level of the QR code.
        #
        # This is directly passed to rqrcode_core as the +level+ argument.
        #
        # Default: nil (i.e. let rqrcode_core decide)
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 'test', size: 100, level: :l)
        attr_accessor :level

        # The mode of the QR code, i.e. which data it holds.
        #
        # This is directly passed to rqrcode_core as the +mode+ argument.
        #
        # Default: nil (i.e. let rqrcode_core decide)
        #
        # Examples:
        #
        #   #>pdf-canvas100
        #   canvas.draw(:qrcode, data: 'test', size: 100, mode: :kanji)
        attr_accessor :mode

        # Creates a QRCode object.
        def initialize
          @data = @size = @code_size = @max_code_size = @level = @mode = nil
          @at = [0, 0]
          @dark_color = 'black'
          @light_color = nil
        end

        # Configures the QRCode object and returns self.
        #
        # The following arguments are allowed:
        #
        # :at:: The position of the bottom-left corner.
        # :size:: The size of the whole rendered QR code.
        # :dark_color:: The color used for the dark QR code modules ('pixels').
        # :light_color:: The color used for the light QR code modules ('pixels').
        # :data:: The data for the QR code.
        # :code_size:: The code size of the QR code.
        # :max_code_size:: The maximum code size of the QR code.
        # :level:: The error correction level of the QR code
        # :mode:: The mode of the of the QR code.
        #
        # Any arguments not specified are not modified and retain their old value, see the attribute
        # methods for the inital default values.
        def configure(at: nil, size: nil, dark_color: nil, light_color: nil,
                      data: nil, code_size: nil, max_code_size: nil, level: nil, mode: nil)
          @at = at if at
          @size = size if size
          @dark_color = dark_color if dark_color
          @light_color = light_color if light_color
          @data = data if data
          @code_size = code_size if code_size
          @max_code_size = max_code_size if max_code_size
          @level = level if level
          @mode = mode if mode
          self
        end

        # Draws the QRCode object onto the given Canvas, with the bottom-left corner at the position
        # specified by #at and the size specified by #size.
        def draw(canvas)
          qrcode = RQRCodeCore::QRCode.new(data, size: code_size, max_size: max_code_size,
                                           level: level, mode: mode)

          canvas.save_graphics_state do
            canvas.translate(*at)
            canvas.fill_color(light_color).rectangle(0, 0, size, size).fill if light_color

            module_count = qrcode.modules.size
            module_size = size.to_f / module_count
            y_start = size - module_size / 2
            canvas.line_cap_style(:butt)
            canvas.line_width(module_size)
            canvas.stroke_color(dark_color)

            qrcode.modules.each_with_index do |row, row_index|
              pattern = [0]
              last_is_dark = row[0]
              row.each do |col|
                if col == last_is_dark
                  pattern[-1] += module_size
                else
                  last_is_dark = !last_is_dark
                  pattern << module_size
                end
              end
              pattern.unshift(0) unless row[0]

              canvas.line_dash_pattern(pattern)
              canvas.line(0, y_start - module_size * row_index,
                          size, y_start - module_size * row_index).
                stroke
            end
          end
        end

      end

    end
  end
end
