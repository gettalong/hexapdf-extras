# frozen_string_literal: true

module HexaPDF
  module Extras
    module Layout
      autoload(:QRCodeBox, 'hexapdf/extras/layout/qr_code_box')
      autoload(:SwissQRBill, 'hexapdf/extras/layout/swiss_qr_bill')
      autoload(:ZintBox, 'hexapdf/extras/layout/zint_box')
    end
  end
end
