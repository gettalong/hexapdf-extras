# frozen_string_literal: true

require 'hexapdf/configuration'

module HexaPDF
  module Extras
    autoload(:GraphicObject, 'hexapdf/extras/graphic_object')
    autoload(:Layout, 'hexapdf/extras/layout')
  end
end

HexaPDF::DefaultDocumentConfiguration['graphic_object.map'][:qrcode] =
  'HexaPDF::Extras::GraphicObject::QRCode'

HexaPDF::DefaultDocumentConfiguration['layout.boxes.map'][:qrcode] =
  'HexaPDF::Extras::Layout::QRCodeBox'
