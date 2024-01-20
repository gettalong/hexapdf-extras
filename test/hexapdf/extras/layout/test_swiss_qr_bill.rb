require 'test_helper'
require 'hexapdf'
require 'hexapdf/extras'
require 'hexapdf/extras/layout/swiss_qr_bill'

using HexaPDF::Extras::Layout::NumericMeasurementHelper

describe HexaPDF::Extras::Layout::SwissQRBill do
  def create_box(data, **kwargs)
    HexaPDF::Extras::Layout::SwissQRBill.new(data: data, **kwargs)
  end

  def data
    @data ||= {
     creditor: {
       iban: "CH4431999123000889012",
       name: "Max Muster & Söhne",
       address_line1: "Musterstrasse",
       address_line2: "123",
       postal_code: "8000",
       town: "Seldwyla",
       country: "CH",
     },
     debtor: {
       address_type: :combined,
       name: "Simon Muster",
       address_line1: "Musterstrasse 1",
       address_line2: "8000 Seldwyla",
       country: "CH"
     },
     lang: :de,
     amount: 2500.25,
     currency: 'CHF',
    }
  end

  before do
    @error_class = HexaPDF::Extras::Layout::SwissQRBill::Error
  end

  describe "initialize" do
    it "overrides any set width or height" do
      box = create_box(data, width: 10, height: 15)
      assert_equal(210.mm, box.width)
      assert_equal(105.mm, box.height)
    end

    describe "data validation" do
      def assert_invalid_data(data = self.data, message)
        err = assert_raises(@error_class) { create_box(data) }
        assert_match(message, err.message)
      end

      it "ensures a correct currency value" do
        assert_equal('EUR', create_box(data.update(currency: 'EUR')).data[:currency])
        assert_equal('CHF', create_box(data.update(currency: 'CHF')).data[:currency])
        assert_invalid_data(data.update(currency: 'USD'), /field :currency/)
      end

      it "ensure a correct amount value" do
        assert_invalid_data(data.update(amount: 0.001), /field :amount/)
        assert_invalid_data(data.update(amount: 1_000_000_000), /field :amount/)
        data.update(amount: 0.00)
        assert_equal('NICHT ZUR ZAHLUNG VERWENDEN', create_box(data).data[:message])
      end

      it "ensures the creditor value exists" do
        data.delete(:creditor)
        assert_invalid_data(/:creditor is missing/)
      end

      it "ensures a correct iban value in the creditor field" do
        data[:creditor].delete(:iban)
        assert_invalid_data(/:iban of :creditor is missing/)
        data[:creditor][:iban] = 'CH44 319 39912300088901 2'
        assert_invalid_data(/:iban of :creditor.*21/)
        data[:creditor][:iban] = 'CH4431999123000889013'
        assert_invalid_data(/:iban of :creditor.*invalid check digits/)
        data[:creditor][:iban] = 'CH4431999123000889012'
        assert(create_box(data))
      end

      it "sets the address type to structured by default" do
        assert_equal(:structured, create_box(data, width: 10, height: 15).data[:creditor][:address_type])
      end

      it "ensures a correct address type" do
        data[:creditor].update(address_type: :invalid)
        assert_invalid_data(/Address type must be/)
      end

      it "ensures a name for an address exists and has a valid length" do
        data[:creditor][:name] = 'a' * 71
        assert_invalid_data(/Name in address.*70/)
        data[:creditor].delete(:name)
        assert_invalid_data(/Name in address must be provided/)
      end

      it "ensures that address line 1 has a valid length" do
        data[:creditor][:address_line1] = 'a' * 71
        assert_invalid_data(/Address line 1.*70/)
      end

      it "ensures a correct country code" do
        data[:creditor][:country] = 'AMS'
        assert_invalid_data(/Country must.*ISO-3166-1/)
        data[:creditor].delete(:country)
        assert_invalid_data(/Country must be provided/)
      end

      describe "ensures a correct structured address" do
        it "ensures that address line 2 has a valid length" do
          data[:creditor][:address_line2] = 'a' * 17
          assert_invalid_data(/Address line 2.*structured.*16/)
        end

        it "ensures that the postal code exists and has a valid length" do
          data[:creditor][:postal_code] = 'a' * 17
          assert_invalid_data(/Postal code.*16/)
          data[:creditor].delete(:postal_code)
          assert_invalid_data(/Postal code must be provided.*structured/)
        end

        it "ensures that the town exists and has a valid length" do
          data[:creditor][:town] = 'a' * 36
          assert_invalid_data(/Town.*35/)
          data[:creditor].delete(:town)
          assert_invalid_data(/Town must be provided.*structured/)
        end
      end

      describe "ensures a correct combined address" do
        it "ensures that address line 2 exists and has a valid length" do
          data[:debtor][:address_line2] = 'a' * 71
          assert_invalid_data(/Address line 2.*combined.*70/)
          data[:debtor].delete(:address_line2)
          assert_invalid_data(/Address line 2 must be provided.*combined/)
        end

        it "ensures that the postal code does not exist" do
          data[:debtor][:postal_code] = 'a'
          assert_invalid_data(/Postal code must not be provided.*combined/)
        end

        it "ensures that the town exists and has a valid length" do
          data[:debtor][:town] = 'a'
          assert_invalid_data(/Town must not be provided.*combined/)
        end
      end

      describe "reference" do
        it "ensures the QRR reference value exists and is valid" do
          data[:reference_type] = 'QRR'
          assert_invalid_data(/:reference must be filled.*QRR/)
          data[:reference] = 'adsfads'
          assert_invalid_data(/:reference for QRR.*27/)
          data[:reference] = '210000000003139471430009011'
          assert_invalid_data(/:reference for QRR.*invalid check digit.*7/)
          data[:reference] = '21000000000313947143000901'
          assert_equal('7', create_box(data).data[:reference][26])
          data[:reference] = '210000000 0031394 71430009017'
          assert(create_box(data))
        end

        it "ensures the SCOR reference value exists and is valid" do
          data[:reference_type] = 'SCOR'
          assert_invalid_data(/:reference must be filled.*SCOR/)
          data[:reference] = 'RF11'
          assert_invalid_data(/:reference for SCOR.*5 and 25/)
          data[:reference] = 'RFa' * 9
          assert_invalid_data(/:reference for SCOR.*5 and 25/)
          data[:reference] = 'RF123323;ö'
          assert_invalid_data(/:reference for SCOR.*alpha-numeric/)
          data[:reference] = 'a' * 20
          assert_invalid_data(/:reference for SCOR must start.*RF/)
          data[:reference] = 'RFabcdefgh'
          assert_invalid_data(/:reference for SCOR must start.*RF and check digits/)
          data[:reference] = 'RF 48 5000056789012345d'
          assert_invalid_data(/:reference for SCOR has invalid check digits/)
          data[:reference] = 'RF 48 5000056789012345'
          assert(create_box(data))
        end

        it "ensures that no reference value is specified for a NON type" do
          data[:reference_type] = 'NON'
          data[:reference] = 'something'
          assert_invalid_data(/:reference must not be provided.*NON/)
        end

        it "ensures a valid reference_type value" do
          data[:reference_type] = 'OTHER'
          assert_invalid_data(/:reference_type must be one of/)
        end
      end

      it "ensures a correct message value" do
        data[:message] = 'a' * 141
        assert_invalid_data(/:message must not contain.*140/)
      end

      it "ensures a correct billing information value" do
        data[:billing_information] = 'a' * 141
        assert_invalid_data(/:billing_information must not contain.*140/)
      end

      it "ensures a total combined length of message + billing_information of max 140 characters" do
        data[:message] = 'a' * 80
        data[:billing_information] = 'a' * 80
        assert_invalid_data(/:message and :billing_information together.*140/)
      end

      it "ensures a correct alternative schemes value" do
        data[:alternative_schemes] = 'a' * 101
        assert_invalid_data(/alternative_schemes.*not more than 100/)
        data[:alternative_schemes] = ['a', 'b', 'c']
        assert_invalid_data(/alternative_schemes.*at most contain 2 strings/)
      end
    end
  end

  describe "draw" do
    before do
      @doc = HexaPDF::Document.new
      @composer = @doc.pages.add.canvas.composer(margin: 0)
    end

    it "works with all information filled in" do
      data[:reference_type] = 'QRR'
      data[:reference] = '210000000 0031394 71430009017'
      data[:message] = 'Please just pay the bills, Jim!'
      data[:billing_information] = '//S/hit/30/50/what/do/I/do/'
      data[:alternative_schemes] = 'ebill/here/comes/data'
      assert(@composer.box(:swiss_qr_bill, data: data))
    end

    it "works with no amount and no debtor" do
      data.delete(:debtor)
      data.delete(:amount)
      assert(@composer.box(:swiss_qr_bill, data: data))
    end

    it "fails if the content is too big for the box" do
      box = create_box(data)
      box.data[:message] = 'x' * 1400
      err = assert_raises(HexaPDF::Error) { @composer.draw_box(box) }
      assert_match(/Swiss QR-bill could not be fit/, err.message)
    end
  end
end
