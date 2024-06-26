require 'test_helper'
require 'hexapdf'
require 'hexapdf/extras/layout/qr_code_box'

describe HexaPDF::Extras::Layout::QRCodeBox do
  def create_box(**kwargs)
    HexaPDF::Extras::Layout::QRCodeBox.new(**kwargs)
  end

  before do
    @frame = HexaPDF::Layout::Frame.new(0, 0, 100, 100)
  end

  describe "initialize" do
    it "can take the common box arguments" do
      box = create_box(width: 10, height: 15)
      assert_equal(10, box.width)
      assert_equal(15, box.height)
    end

    it "creates the QRCode graphic object" do
      box = create_box(data: 'test', level: :l)
      assert_equal(:l, box.qr_code.level)
      assert_equal('test', box.qr_code.data)
    end
  end

  describe "fit" do
    it "uses the smaller value of width/height for the dimensions if smaller than available_width/height" do
      [{width: 10}, {width: 10, height: 50}, {height: 10}, {width: 50, height: 10}].each do |args|
        box = create_box(**args)
        assert(box.fit(100, 100, @frame).success?)
        assert_equal(10, box.width)
        assert_equal(10, box.height)
        assert_equal(10, box.qr_code.size)
      end
    end

    it "uses the smaller value of available_width/height for the dimensions" do
      box = create_box
      assert(box.fit(10, 20, @frame).success?)
      assert_equal(10, box.width)
      assert_equal(10, box.height)
      assert_equal(10, box.qr_code.size)

      assert(box.fit(20, 15, @frame).success?)
      assert_equal(15, box.width)
      assert_equal(15, box.height)
      assert_equal(15, box.qr_code.size)
    end

    it "takes the border and padding into account for the QR code size" do
      box = create_box(style: {padding: [1, 2], border: {width: [3, 4]}})
      assert(box.fit(100, 100, @frame).success?)
      assert_equal(88, box.qr_code.size)
      assert_equal(100, box.width)
      assert_equal(96, box.height)

      box = create_box(style: {padding: [2, 1], border: {width: [4, 3]}})
      assert(box.fit(100, 100, @frame).success?)
      assert_equal(88, box.qr_code.size)
      assert_equal(96, box.width)
      assert_equal(100, box.height)

      box = create_box(style: {padding: [5, 5, 5, 0], border: {width: [2, 2, 2, 0]}})
      assert(box.fit(50, 100, @frame).success?)
      assert_equal(43, box.qr_code.size)
      assert_equal(50, box.width)
      assert_equal(57, box.height)
    end
  end

  describe "draw" do
    it "draws the qrcode" do
      box = create_box(width: 10)
      assert(box.fit(100, 100, @frame).success?)

      canvas = Minitest::Mock.new
      canvas.expect(:draw, nil, [box.qr_code])
      box.draw(canvas, 5, 7)
      assert_equal([5, 7], box.qr_code.at)
      canvas.verify
    end
  end
end
