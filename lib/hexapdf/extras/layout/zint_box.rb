# frozen_string_literal: true

require 'hexapdf/layout/box'
require 'hexapdf/extras/graphic_object/zint'

module HexaPDF
  module Extras
    module Layout

      # A ZintBox object is used for displaying a barcode.
      #
      # Internally, GraphicObject::Zint is used, so any option except +at+, +width+ and +height+
      # supported there can be used here.
      #
      # The size of the barcode is determined by the width and height of the box. For details on how
      # this works see GraphicObject::Zint#width.
      #
      # Example:
      #
      #   #>pdf-composer100
      #   composer.box(:barcode, height: 30, style: {position: :float},
      #                data: {value: 'Test', symbology: :qrcode})
      #   composer.box(:barcode, width: 60, style: {position: :float},
      #                data: {value: 'Test', symbology: :code128, bgcolour: 'ff0000',
      #                       fgcolour: '00ffff'})
      #   composer.box(:barcode, width: 30, height: 50, style: {position: :float},
      #                data: {value: 'Test', symbology: :code128})
      #   composer.box(:barcode, data: {value: 'Test', symbology: :code128})
      class ZintBox < HexaPDF::Layout::ImageBox

        # The HexaPDF::Extras::GraphicObject::Zint object that will be drawn.
        attr_reader :barcode

        # Creates a new ZintBox object with the given arguments.
        #
        # The argument +data+ needs to contain a hash with the arguments that are passed on to
        # GraphicObject::Zint.
        #
        # Note: Although this box derives from ImageBox, the #image method will only return the
        # correct object after #fit was called.
        def initialize(data:, **kwargs)
          super(image: nil, **kwargs)
          @barcode = GraphicObject::Zint.configure(**data)
        end

        private

        # Fits the barcode into the given area.
        def fit_content(available_width, available_height, frame)
          @image ||= @barcode.form_xobject(frame.document)
          super
        end

      end

    end
  end
end
