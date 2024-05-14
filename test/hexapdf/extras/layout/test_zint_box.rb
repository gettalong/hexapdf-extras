require 'test_helper'
require 'hexapdf'
require 'hexapdf/extras/layout/zint_box'

describe HexaPDF::Extras::Layout::ZintBox do
  def create_box(**kwargs)
    HexaPDF::Extras::Layout::ZintBox.new(**kwargs)
  end

  describe "initialize" do
    it "takes the common box arguments" do
      box = create_box(width: 10, height: 15, data: {})
      assert_equal(10, box.width)
      assert_equal(15, box.height)
    end

    it "creates the zint barcode graphic object" do
      box = create_box(data: {value: 'test', symbology: :code128})
      assert_equal({value: 'test', symbology: 20}, box.barcode.zint_kws)
    end
  end

  describe "fit" do
    it "creates the form xobject and uses that as image for its superclass" do
      doc = HexaPDF::Document.new
      frame = HexaPDF::Layout::Frame.new(0, 0, 100, 100, context: doc.pages.add)

      box = create_box(data: {value: 'test', symbology: :code128})
      assert_nil(box.image)
      box.fit(100, 100, frame)
      assert_equal(:Form, box.image[:Subtype])
    end
  end
end
