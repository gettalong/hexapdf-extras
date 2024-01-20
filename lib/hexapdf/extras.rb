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

HexaPDF::DefaultDocumentConfiguration['layout.boxes.map'][:swiss_qr_bill] =
  'HexaPDF::Extras::Layout::SwissQRBill'

# These values comes from the "Style Guide QR-bill", available at
# https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/style-guide-qr-bill-en.pdf
font = '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf'
font_bold = '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf'
HexaPDF::DefaultDocumentConfiguration['layout.swiss_qr_bill'] = {
  'section.heading.font' => font_bold,
  'section.heading.font_size' => 11,
  'payment.heading.font' => font_bold,
  'payment.heading.font_size' => 8,
  'payment.heading.line_height' => 11,
  'payment.value.font' => font,
  'payment.value.font_size' => 10,
  'payment.value.line_height' => 11,
  'receipt.heading.font' => font_bold,
  'receipt.heading.font_size' => 6,
  'receipt.heading.line_height' => 9,
  'receipt.value.font' => font,
  'receipt.value.font_size' => 8,
  'receipt.value.line_height' => 9,
  'alternative_procedures.heading.font' => font_bold,
  'alternative_procedures.heading.font_size' => 7,
  'alternative_procedures.heading.line_height' => 8,
  'alternative_procedures.value.font' => font,
  'alternative_procedures.value.font_size' => 7,
  'alternative_procedures.value.line_height' => 8,
}
