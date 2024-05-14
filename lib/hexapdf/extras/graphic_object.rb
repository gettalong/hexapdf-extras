# frozen_string_literal: true

module HexaPDF
  module Extras
    module GraphicObject
      autoload(:QRCode, 'hexapdf/extras/graphic_object/qr_code')
      autoload(:Zint, 'hexapdf/extras/graphic_object/zint')
    end
  end
end
