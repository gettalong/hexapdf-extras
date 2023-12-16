# frozen_string_literal: true

require 'hexapdf/layout/box'
require 'hexapdf/extras/graphic_object/qr_code'

module HexaPDF
  module Extras
    module Layout

      # A QRCodeBox object is used for displaying a QR code.
      #
      # The size of the QR code is determined by the width and height of the box (to be exact: by
      # the smaller of the two values). The QR code is always placed at the top left corner of the
      # box.
      #
      # Internally, HexaPDF::Extras::GraphicObject::QRCode is used, so any option except +at+ and
      # +size+ supported there can be used here.
      #
      # Example:
      #
      #   #>pdf-composer100
      #   composer.box(:qrcode, height: 50, data: 'Test', style: {position: :float})
      #   composer.box(:qrcode, width: 20, data: 'Test', dark_color: 'red', style: {position: :float})
      #   composer.box(:qrcode, width: 30, height: 50, data: 'Test', dark_color: 'green',
      #                style: {position: :float})
      #   composer.box(:qrcode, data: 'Test', dark_color: 'blue')
      class QRCodeBox < HexaPDF::Layout::Box

        # The HexaPDF::Extras::GraphicObject::QRCode object that will be drawn.
        attr_reader :qr_code

        # Creates a new QRCodeBox object with the given arguments (see
        # HexaPDF::Extras::GraphicObject::QRCode for details).
        #
        # At least +data+ needs to be specified.
        def initialize(dark_color: nil, light_color: nil, data: nil, code_size: nil,
                       max_code_size: nil, level: nil, mode: nil, **kwargs)
          super(**kwargs)
          @qr_code = HexaPDF::Extras::GraphicObject::QRCode.configure(
            dark_color: dark_color, light_color: light_color, data: data, code_size: code_size,
            max_code_size: max_code_size, level: level, mode: mode
          )
        end

        # Fits the QRCode into the given area.
        def fit(available_width, available_height, _frame)
          super
          @qr_code.size = [content_width, content_height].min
          @width = @qr_code.size + reserved_width
          @height = @qr_code.size + reserved_height
          @fit_successful = (@width <= available_width && @height <= available_height)
        end

        private

        # Draws the QR code onto the canvas at position [x, y].
        def draw_content(canvas, x, y)
          @qr_code.at = [x, y]
          canvas.draw(@qr_code)
        end

      end

    end
  end
end
