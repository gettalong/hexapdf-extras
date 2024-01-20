# frozen_string_literal: true

require 'hexapdf/error'
require 'hexapdf/layout/box'
require 'hexapdf/extras/layout'

module HexaPDF::Extras::Layout::NumericMeasurementHelper #:nodoc:
  refine Numeric do
    def mm
      self * 72 / 25.4
    end
  end
end

using HexaPDF::Extras::Layout::NumericMeasurementHelper

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

module HexaPDF
  module Extras
    module Layout

      # Displays a Swiss QR-bill.
      #
      # This class implements version 2.2 of the Swiss QR-bill specification but takes into account
      # version 2.3 where appropriate.
      #
      #
      # == Requirements
      #
      # * Liberation Sans TrueType font installed in standard Linux path (or changed via the
      #   configuration option, see next section)
      # * Rubygem +rqrcode_core+ for generating the QR code
      #
      #
      # == Configuration option 'layout.swiss_qr_bill'
      #
      # The configuration option 'layout.swiss_qr_bill' is a hash containing styling information for
      # the various text parts: section heading, payment heading/value, receipt heading/value and
      # the alternative procedures. The default values are taking from the QR-bill style guide.
      #
      # The keys of this hash are strings of the form 'part.subpart.property' where
      #
      # * 'part' can be 'section', 'payment', 'receipt', or 'alternative_procedures',
      # * 'subpart' can be 'heading' or 'value' (the latter not for 'section'),
      # * 'property' can be 'font', 'font_size' or 'line_height' (the latter not for 'section').
      #
      # The default font is Liberation Sans which is one of the four allowed fonts (the others being
      # Arial, Frutiger, and Helvetica). The font files themselves are *not* included and the 'font'
      # property, by default, references the standard Linux path where the fonts would be found.
      # Note that all '*.heading.font' values should reference the bold version of the font whereas
      # the '*.value.font' values should reference the regular version.
      #
      #
      # == Data Structure
      #
      # All the necessary information for generating the Swiss QR-bill is provided on
      # initialization. The following keys can be used:
      #
      # :lang::
      #     The language to use for the literal text strings appearing in the QR-bill. One of :en,
      #     :de, :fr or :it.
      #
      #     Defaults to :en if not specified.
      #
      # :creditor::
      #     (required) The creditor of the transaction. This is a hash that can contain the
      #     following elements:
      #
      #     :iban::
      #         (required) The IBAN of the creditor (21 characters, no spaces, only IBANs for CH or
      #         LI). Note that the IBAN is not checked for validity.
      #
      #     :name::
      #         (required) The name of the creditor (maximum 70 characters).
      #
      #     :address_type::
      #         (required) The type of address, either :structured or :combined. Defaults to
      #         :structured which is the only choice in version 2.3 of the specification.
      #
      #     :address_line1::
      #         The first line of the creditor's address (maximum 70 characters). In case of a
      #         structured address, this is the street. Otherwise this has to be the street and
      #         building number together.
      #
      #     :address_line2::
      #         The second line of the creditor's address. In case of a structured address, this
      #         has to be the building number (maximum 16 characters). Otherwise it has to be the
      #         postal code and town (maximum 70 characters).
      #
      #     :postal_code::
      #         The postal code of the creditor's address (maximum 16 characters, only for
      #         structured addresses).
      #
      #     :town::
      #         The town from the creditor's address (maximum 35 characters, only for structured
      #         addresses).
      #
      #     :country::
      #         (required) The country from the creditor's address (ISO 3166-1 two-letter country
      #         code).
      #
      # :debtor::
      #     The debtor information for the transaction. This information is optional but if used
      #     some elements are required. The value is a hash that can contain the same elements as
      #     the +:creditor+ key with the exception of the +:iban+.
      #
      # :amount::
      #     The payment amount (between 0.01 and 999,999,999.99). If not filled in, a blank field is
      #     shown for adding the amount by hand later. If the amount is set to zero, it means that
      #     the QR-bill should be used as notification and the :message is set according to the
      #     specification.
      #
      # :currency::
      #     (required) The payment currency (either CHF or EUR).
      #
      # :reference_type::
      #     The payment reference type (either QRR, SCOR or NON). Defaults to NON.
      #
      # :reference::
      #     The structured reference data. All whitespace is removed before processing.
      #
      #     In case of a QRR reference, the value has to be a 26 digit reference without check digit
      #     or a 27 digit reference with check digit. The check digit is validated.
      #
      #     In case of a SCOR reference, the value has to contain between 5 and 25 alpha-numeric
      #     characters. The check digits are validated.
      #
      # :message::
      #     Additional, unstructured information (maximum 140 characters).
      #
      # :billing_information::
      #     Billing information for automated booking of the payment (maximum 140 characters).
      #
      # :alternative_schemes::
      #     Alternative schemes parameters. Either a single string with a maximum of 100 characters
      #     or an array of two such strings.
      #
      # == Example
      #
      #   HexaPDF::Composer.create("sample-qr-bill.pdf", margin: 0) do |composer|
      #     data = {
      #      lang: :de,
      #      creditor: {
      #        iban: "CH44 3199 9123 0008 8901 2",
      #        name: "Max Muster & Söhne",
      #        address_line1: "Musterstrasse",
      #        address_line2: "123",
      #        postal_code: "8000",
      #        town: "Seldwyla",
      #        country: "CH",
      #      },
      #      debtor: {
      #        address_type: :combined,
      #        name: "Simon Muster",
      #        address_line1: "Musterstrasse 1",
      #        address_line2: "8000 Seldwyla",
      #        country: "CH"
      #      },
      #      amount: 2500.25,
      #      currency: 'CHF',
      #     }
      #     composer.swiss_qr_bill(data: data, valign: :bottom)
      #   end
      #
      # == References
      #
      # * Website https://www.six-group.com/en/products-services/banking-services/billing-and-payments/qr-bill.html
      # * 2.2 Specification https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/ig-qr-bill-v2.2-en.pdf
      # * 2.3 Specification https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/ig-qr-bill-v2.3-en.pdf
      # * Style guide https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/style-guide-qr-bill-en.pdf
      class SwissQRBill < HexaPDF::Layout::Box

        # Thrown when an error occurs when working with the SwissQRBill class.
        class Error < HexaPDF::Error
        end

        # Mapping of the English text literals to their German, French and Italian counterparts,
        # taken from Annex C of the specification.
        TEXT_LITERALS = { #:nodoc:
          de: {
            'Payment part' => 'Zahlteil',
            'Receipt' => 'Empfangsschein',
            'Account / Payable to' => 'Konto / Zahlbar an',
            'Reference' => 'Referenz',
            'Additional information' => 'Zusätzliche Informationen',
            'Payable by' => 'Zahlbar durch',
            'Payable by (name/address)' => 'Zahlbar durch (Name/Adresse)',
            'Currency' => 'Währung',
            'Amount' => 'Betrag',
            'Acceptance point' => 'Annahmestelle',
            'In favour of' => 'Zugunsten',
            'DO NOT USE FOR PAYMENT' => 'NICHT ZUR ZAHLUNG VERWENDEN',
          },
          fr: {
            'Payment part' => 'Section paiement',
            'Receipt' => 'Récépissé',
            'Account / Payable to' => 'Compte / Payable à',
            'Reference' => 'Référence',
            'Additional information' => 'Information supplémentaires',
            'Payable by' => 'Payable par',
            'Payable by (name/address)' => 'Payable par (nom/address)',
            'Currency' => 'Monnaie',
            'Amount' => 'Montant',
            'Acceptance point' => 'Point de dépôt',
            'In favour of' => 'En faveur de',
            'DO NOT USE FOR PAYMENT' => 'NE PAS UTILISER POUR LE PAIEMENT',
          },
          it: {
            'Payment part' => 'Sezione pagamento',
            'Receipt' => 'Ricevuta',
            'Account / Payable to' => 'Conto / Pagabile a',
            'Reference' => 'Riferimento',
            'Additional information' => 'Informazioni supplementari',
            'Payable by' => 'Pagabile da',
            'Payable by (name/address)' => 'Pagabile da (nome/indirizzo)',
            'Currency' => 'Value date ',
            'Amount' => 'Importo',
            'Acceptance point' => 'Punto di accettazione',
            'In favour of' => 'A favore di',
            'DO NOT USE FOR PAYMENT' => 'NON UTILIZZARE PER IL PAGAMENTO',
          }
        }

        # The payment data - see the SwissQRBill class documentation for details.
        attr_reader :data

        # Creates a new SwissQRBill object for the given payment +data+ (see the class documentation
        # for details).
        #
        # If the arguments +width+ and +height+ are provided, they are ignored since the QR-bill has
        # a fixed size of 210mm x 105mm.
        def initialize(data:, **kwargs)
          super(**kwargs, width: 210.mm, height: 105.mm)
          validate_data(data)
        end

        private

        QRR_MODULO10_TABLE = [ #:nodoc:
          [0, 9, 4, 6, 8, 2, 7, 1, 3, 5],
          [9, 4, 6, 8, 2, 7, 1, 3, 5, 0],
          [4, 6, 8, 2, 7, 1, 3, 5, 0, 9],
          [6, 8, 2, 7, 1, 3, 5, 0, 9, 4],
          [8, 2, 7, 1, 3, 5, 0, 9, 4, 6],
          [2, 7, 1, 3, 5, 0, 9, 4, 6, 8],
          [7, 1, 3, 5, 0, 9, 4, 6, 8, 2],
          [1, 3, 5, 0, 9, 4, 6, 8, 2, 7],
          [3, 5, 0, 9, 4, 6, 8, 2, 7, 1],
          [5, 0, 9, 4, 6, 8, 2, 7, 1, 3]
        ].freeze

        # Validates the given data and raises an error if the data is not valid
        def validate_data(data)
          @data = data

          if @data[:currency] != 'EUR' && @data[:currency] != 'CHF'
            raise Error, "Data field :currency must be EUR or CHR, not #{@data[:currency].inspect}"
          end

          if @data[:amount] == 0
            @data[:message] = text('DO NOT USE FOR PAYMENT')
          elsif @data[:amount] && (@data[:amount] < 0.01 || @data[:amount] > 999_999_999.99)
            raise Error, "Data field :amount must be between 0.01 and 999_999_999.99"
          end

          validate_address = lambda do |hash|
            hash[:address_type] ||= :structured
            if hash[:address_type] != :structured && hash[:address_type] != :combined
              raise Error, "Address type must be :structured or :combined, not #{hash[:address_type]}"
            end
            structured = (hash[:address_type] == :structured)

            if (value = hash[:name]) && value.size > 70
              raise Error, "Name in addresss must not contain more than 70 characters"
            elsif !value
              raise Error, "Name in address must be provided"
            end

            if hash[:address_line1] && hash[:address_line1].size > 70
              raise Error, "Address line 1 must not contain more than 70 characters"
            end

            if (value = hash[:address_line2])
              if structured && value.size > 16
                raise Error, "Address line 2 of a structured address must not contain " \
                  "more than 16 characters"
              elsif value.size > 70
                raise Error, "Address line 2 of a combined address must not contain " \
                  "more than 70 characters"
              end
            elsif !structured
              raise Error, "Address line 2 must be provided for a combined address"
            end

            if (value = hash[:postal_code])
              if !structured
                raise Error, "Postal code must not be provided for a combined address"
              elsif value.size > 16
                raise Error, "Postal code must not contain more than 16 characters"
              end
            elsif structured
              raise Error, "Postal code must be provided for a structured address"
            end

            if (value = hash[:town])
              if !structured
                raise Error, "Town must not be provided for a combined address"
              elsif value.size > 35
                raise Error, "Town must not contain more than 35 characters"
              end
            elsif structured
              raise Error, "Town must be provided for a structured address"
            end

            if (value = hash[:country]) && value.size != 2
              raise Error, "Country must be a two-letter ISO-3166-1 code"
            elsif !value
              raise Error, "Country must be provided"
            end
          end
          validate_address.call(@data[:creditor])
          validate_address.call(@data[:debtor]) if @data[:debtor]

          @data[:reference_type] ||= "NON"
          case @data[:reference_type]
          when "QRR"
            value = @data[:reference]
            unless value
              raise Error, "Data field :reference must be filled in for QRR reference type"
            end
            value.gsub!(/\s*/, '')
            if value !~ /\A\d{26,27}\z/
              raise Error, "Data field :reference for QRR must contain 26 or 27 digits"
            end
            result = value[0, 26].each_codepoint.inject(0) do |memo, codepoint|
              QRR_MODULO10_TABLE[memo][codepoint - 48]
            end
            check_digit = (10 - result) % 10
            value << check_digit.to_s if value.size == 26
            if value[26].to_i != check_digit
              raise Error, "Data field :reference for QRR contains an invalid check digit, " \
                "should be #{check_digit}"
            end
          when "SCOR"
            value = @data[:reference]
            unless value
              raise Error, "Data field :reference must be filled in for SCOR reference type"
            end
            value.gsub!(/\s*/, '')
            if value !~ /\A\w{5,25}\z/
              raise Error, "Data field :reference for SCOR must contain between 5 and 25 " \
                "alpha-numeric characters"
            elsif value !~ /\ARF\d\d/
              raise Error, "Data field :reference for SCOR must start with RF and check digits"
            end
            # See https://www.mobilefish.com/services/creditor_reference/creditor_reference.php
            result = "#{value[4..-1]}#{value[0, 4]}".upcase.gsub(/[A-Z]/) {|c| c.ord - 55 }.to_i % 97
            unless result == 1
              raise Error, "Data field :reference for SCOR has invalid check digits"
            end
          when "NON"
            if @data[:reference]
              raise Error, "Data field :reference must not be provided for NON reference type"
            end
          else
            raise Error, "Data field :reference_type must be one of QRR, SCOR or NON"
          end

          if @data[:message] && @data[:message].size > 140
            raise Error, "Data field :message must not contain more than 140 characters"
          end
          if @data[:billing_information] && @data[:billing_information].size > 140
            raise Error, "Data field :billing_information must not contain more than 140 characters"
          end
          if (@data[:message].to_s + @data[:billing_information].to_s).size > 140
            raise Error, "Data fields :message and :billing_information together must not " \
              "contain more than 140 characters"
          end

          @data[:alternative_schemes] = Array(@data[:alternative_schemes])
          if @data[:alternative_schemes].any? {|as| as.size > 100 } ||
              @data[:alternative_schemes].size > 2
            raise Error, "Data field :alternative_schemes must at most contain 2 strings with " \
              "not more than 100 characters each"
          end
        end

        # Draws the SwissQRBill onto the canvas at position [x, y].
        def draw_content(canvas, x, y)
          layout = canvas.context.document.layout
          frame = HexaPDF::Layout::Frame.new(0, 0, width, height, context: canvas.context)
          box_fitter = HexaPDF::Layout::BoxFitter.new([frame])
          styles = set_up_styles(canvas.context.document.config['layout.swiss_qr_bill'], layout)

          box_fitter.fit(receipt(layout, styles))
          box_fitter.fit(payment(layout, styles, qr_code_cross(canvas.context.document)))
          unless box_fitter.fit_successful?
            raise HexaPDF::Error, "The Swiss QR-bill could not be fit"
          end

          canvas.translate(x, y) do
            box_fitter.fit_results.each {|fit_result| fit_result.draw(canvas)}
            canvas.stroke_color(0).line_width(0.5).line_dash_pattern(2).
              line(62.mm, 0, 62.mm, 105.mm).
              line(0, 105.mm, 210.mm, 105.mm).stroke
            canvas.font('ZapfDingbats', size: 15).text("✂", at: [5.mm, 103.1.mm])
            canvas.font('ZapfDingbats', size: 15).text_matrix(0, -1, 1, 0, 60.175.mm, 100.mm).text("✂")
          end
        end

        # Returns a hash with styles that are used throughout the QR-bill creation for consistency.
        def set_up_styles(config, layout)
          {
            section_heading: {font_size: config['section.heading.font_size'],
                              font: config['section.heading.font']},
            payment_heading: {font_size: config['payment.heading.font_size'],
                              font: config['payment.heading.font'],
                              line_height: config['payment.heading.line_height'],
                              line_spacing: {type: :fixed, value: config['payment.heading.line_height']}},
            payment_value: {font_size: config['payment.value.font_size'],
                            font: config['payment.value.font'],
                            line_height: config['payment.value.line_height'],
                            line_spacing: {type: :fixed, value: config['payment.value.line_height']},
                            padding: [0, 0, config['payment.value.line_height']]},
            receipt_heading: {font_size: config['receipt.heading.font_size'],
                              font: config['receipt.heading.font'],
                              line_height: config['receipt.heading.line_height'],
                              line_spacing: {type: :fixed, value: config['receipt.heading.line_height']}},
            receipt_value: {font_size: config['receipt.value.font_size'],
                            font: config['receipt.value.font'],
                            line_height: config['receipt.value.line_height'],
                            line_spacing: {type: :fixed, value: config['receipt.value.line_height']},
                            padding: [0, 0, config['receipt.value.line_height']]},
            alternative_procedures_heading: {
              font_size: config['alternative_procedures.heading.font_size'],
              font: config['alternative_procedures.heading.font'],
              line_height: config['alternative_procedures.heading.line_height'],
              line_spacing: {type: :fixed, value: config['alternative_procedures.heading.line_height']}
            },
            alternative_procedures_value: {
              font_size: config['alternative_procedures.value.font_size'],
              font: config['alternative_procedures.value.font'],
              line_height: config['alternative_procedures.value.line_height'],
              line_spacing: {type: :fixed, value: config['alternative_procedures.value.line_height']},
              padding: [0, 0, config['alternative_procedures.value.line_height']]
            },
          }.transform_values! {|value| layout.style(:base).dup.update(**value) }
        end

        # Returns a box containing the receipt part of the QR-bill.
        def receipt(layout, styles)
          layout.container(width: 62.mm, style: {padding: 5.mm, mask_mode: :fill_vertical}) do |col|
            col.text(text('Receipt'), height: 7.mm, style: styles[:section_heading])
            col.container(height: 56.mm) do |info|
              info.text(text('Account / Payable to'), style: styles[:receipt_heading])
              info.text("#{@data[:creditor][:iban]}\n#{address(@data[:creditor])}", style: styles[:receipt_value])

              if @data[:reference_type] != 'NON'
                info.text(text('Reference'), style: styles[:receipt_heading])
                info.text(@data[:reference], style: styles[:receipt_value])
              end

              if @data[:debtor]
                info.text(text('Payable by'), style: styles[:receipt_heading])
                info.text(address(@data[:debtor]), style: styles[:receipt_value])
              else
                info.text(text('Payable by (name/address)'), style: styles[:receipt_heading])
                blank_field(info, 52.mm, 20.mm)
              end
            end
            receipt_amount(col, styles)
            col.text(text('Acceptance point'), style: styles[:receipt_heading], text_align: :right)
          end
        end

        # Adds the appropriate boxes to the given composer for the amount part of the receipt
        # section.
        def receipt_amount(composer, styles)
          composer.container(height: 14.mm) do |amount|
            if @data[:amount]
              amount.column(columns: [26.mm, -1], gaps: 0) do |inner|
                inner.text(text('Currency'), style: styles[:receipt_heading], padding: [0, 0, 1.mm])
                inner.text(@data[:currency], style: styles[:receipt_value])
                inner.text(text('Amount'), style: styles[:receipt_heading], padding: [0, 0, 1.mm])
                inner.text(formatted_amount, style: styles[:receipt_value])
              end
            else
              amount.column(columns: [-1, 31.mm], gaps: 0) do |inner|
                inner.text(text('Currency') + "   " + text("Amount"),
                           style: styles[:receipt_heading], padding: [0, 0, 1.mm])
                inner.text(@data[:currency], style: styles[:receipt_value], mask_mode: :fill)
                inner.box(:base, height: 2)
                blank_field(inner, 30.mm, 10.mm)
              end
            end
          end
        end

        # Returns a box containing the payment part of the QR-bill.
        def payment(layout, styles, cross)
          layout.container(width: 148.mm, style: {padding: 5.mm}) do |col|
            col.container(width: 51.mm, height: 85.mm, style: {mask_mode: :box}) do |left_col|
              left_col.text(text('Payment part'), height: 7.mm, style: styles[:section_heading])
              left_col.box(:qrcode, data: qr_code_data, level: :m, style: {padding: [5.mm, 5.mm, 5.mm, 0.mm]})
              left_col.image(cross, width: 7.mm, position: [19.5.mm, 46.5.mm])
              payment_amount(left_col, styles)
            end
            col.container(height: 85.mm) do |info|
              info.text(text('Account / Payable to'), style: styles[:payment_heading])
              info.text("#{@data[:creditor][:iban]}\n#{address(@data[:creditor])}", style: styles[:payment_value])

              if @data[:reference_type] != 'NON'
                info.text(text('Reference'), style: styles[:payment_heading])
                info.text(@data[:reference], style: styles[:payment_value])
              end

              if @data[:message] || @data[:billing_information]
                info.text(text('Additional information'), style: styles[:payment_heading])
                info.text([@data[:message], @data[:billing_information]].compact.join("\n"), style: styles[:payment_value])
              end

              if @data[:debtor]
                info.text(text('Payable by'), style: styles[:payment_heading])
                info.text(address(@data[:debtor]), style: styles[:payment_value])
              else
                info.text(text('Payable by (name/address)'), style: styles[:payment_heading])
                blank_field(info, 65.mm, 25.mm)
              end
            end
            if @data[:alternative_schemes].size > 0
              @data[:alternative_schemes].each do |as|
                provider, data = *as.split('/', 2)
                col.formatted_text([{text: provider, style: styles[:alternative_procedures_heading]},
                                    {text: data, style: styles[:alternative_procedures_value]}])
              end
            end
          end
        end

        # Adds the appropriate boxes to the given composer for the amount part of the payment
        # section.
        def payment_amount(composer, styles)
          composer.container(height: 22.mm) do |amount|
            if @data[:amount]
              amount.column(columns: [23.mm, -1], gaps: 0) do |inner|
                inner.text(text('Currency'), style: styles[:payment_heading], padding: [0, 0, 1.mm])
                inner.text(@data[:currency], style: styles[:payment_value])
                inner.text(text('Amount'), style: styles[:payment_heading], padding: [0, 0, 1.mm])
                inner.text(formatted_amount, style: styles[:payment_value])
              end
            else
              amount.text(text('Currency') + "    " + text("Amount"),
                          style: styles[:payment_heading], padding: [0, 0, 1.mm])
              amount.column(columns: [-1, 41.mm], gaps: 0) do |inner|
                inner.text(@data[:currency], style: styles[:payment_value])
                blank_field(inner, 40.mm, 15.mm)
              end
            end
          end
        end

        # Returns the correctly localized text for the given string +str+.
        def text(str)
          TEXT_LITERALS.dig(@data[:lang], str) || str
        end

        # Returns a string containing the formatted address for output using the provided data.
        def address(data)
          result = +''
          result << "#{data[:name]}\n"
          if data[:address_type] == :structured
            addr = [data[:address_line1], data[:address_line2]].compact
            result << "#{addr.join(' ')}\n" unless addr.empty?
            result << "#{data[:country]}-#{data[:postal_code]} #{data[:town]}"
          else
            result << "#{data[:address_line1]}\n" if data.key?(:address_line1)
            result << "#{data[:country]}-#{data[:address_line2]}\n"
          end
          result
        end

        # Returns the amount formatted according to the specification.
        def formatted_amount
          a, b = format('%.2f', @data[:amount]).split('.')
          a.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1 ") << '.' << b
        end

        # Creates the content of the QR code using the information provided in #data.
        def qr_code_data
          qr_code_data = []
          add_address_data = lambda do |hash|
            qr_code_data << (hash[:address_type] == :structured ? "S" : "K")
            qr_code_data << hash[:name] <<
              hash[:address_line1].to_s << hash[:address_line2].to_s <<
              hash[:postal_code].to_s << hash[:town].to_s << hash[:country]
          end

          # Header information
          qr_code_data.concat(["SPC", "0200", "1"])

          # Creditor information
          qr_code_data << @data[:creditor][:iban]
          add_address_data.call(@data[:creditor])

          # Ultimate creditor information
          qr_code_data.concat(["", "", "", "", "", "", ""])

          # Amount information
          qr_code_data << (@data[:amount] ? format('%.2f', @data[:amount]) : "") << @data[:currency]

          # Debtor information
          add_address_data.call(@data[:debtor]) if @data[:debtor]

          # Payment reference
          qr_code_data << @data[:reference_type] << @data[:reference].to_s <<
            @data[:message].to_s << "EPD"
          qr_code_data << @data[:billing_information] if @data[:billing_information]

          qr_code_data.join("\r\n")
        end

        # Creates a Form XObject for the Swiss cross that is to be overlaid over the QR code.
        #
        # The measurements are reverse-engineered from the images provided at
        # https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/swiss-cross-graphic-en.zip
        def qr_code_cross(document)
          cross = document.add({Type: :XObject, Subtype: :Form, BBox: [0, 0, 7.mm, 7.mm]})
          canvas = cross.canvas
          canvas.fill_color(1.0).rectangle(0, 0, 7.mm, 7.mm).fill
          canvas.fill_color(0.0).rectangle(0.5.mm, 0.5.mm, 6.mm, 6.mm).fill
          canvas.fill_color(1.0).
            rectangle(2.93.mm, 1.67.mm, 1.17.mm, 3.9.mm).
            rectangle(1.57.mm, 3.04.mm, 3.9.mm, 1.17.mm).
            fill
          cross
        end

        CORNER_MARK_LENGTH = 3.mm # :nodoc:

        # Creates a blank rectangle of the given +width+ and +height+, with corner marks as
        # specified by the specification.
        def blank_field(layout, width, height)
          layout.box(width: width, height: height) do |canvas, box|
            canvas.stroke_color(0).line_width(0.75).
              polyline(0, CORNER_MARK_LENGTH, 0, 0, CORNER_MARK_LENGTH, 0).
              polyline(width - CORNER_MARK_LENGTH, 0, width, 0, width, CORNER_MARK_LENGTH).
              polyline(width, height - CORNER_MARK_LENGTH, width, height, width - CORNER_MARK_LENGTH, height).
              polyline(CORNER_MARK_LENGTH, height, 0, height, 0, height - CORNER_MARK_LENGTH).
              stroke
          end
        end

      end

    end
  end
end
