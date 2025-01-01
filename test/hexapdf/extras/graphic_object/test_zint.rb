require 'test_helper'
require 'hexapdf'
require 'hexapdf/extras/graphic_object/zint'

describe HexaPDF::Extras::GraphicObject::Zint do
  before do
    @obj = HexaPDF::Extras::GraphicObject::Zint.new
  end

  it "allows creation via the ::configure method" do
    obj = HexaPDF::Extras::GraphicObject::Zint.configure(value: 'test')
    assert_equal('test', obj.zint_kws[:value])
  end

  it "creates a default drawing support object" do
    assert_equal([0, 0], @obj.at)
    assert_nil(@obj.width)
    assert_nil(@obj.height)
    assert_equal('Helvetica', @obj.font)
    assert_equal({}, @obj.zint_kws)
  end

  it "allows configuration of the object" do
    assert_same(@obj, @obj.configure(value: 'test', width: 30, symbology: :code128))
    assert_equal('test', @obj.zint_kws[:value])
    assert_equal(::Zint::BARCODE_CODE128, @obj.zint_kws[:symbology])
    assert_equal(30, @obj.width)
    @obj.configure(symbology: ::Zint::BARCODE_DATAMATRIX)
    assert_equal(::Zint::BARCODE_DATAMATRIX, @obj.zint_kws[:symbology])
  end

  describe "draw" do
    before do
      doc = HexaPDF::Document.new
      @canvas = doc.pages.add.canvas
    end

    it "draws a barcode onto the canvas" do
      @obj.configure(value: 'test', width: 50, symbology: :code128)
      @obj.draw(@canvas)
      assert_operators(@canvas.contents,
                       [[:save_graphics_state],
                        [:concatenate_matrix, [0.316456, 0, 0, 0.316456, 0, 0]],
                        [:paint_xobject, [:XO1]],
                        [:restore_graphics_state]])
      assert_operators(@canvas.context.resources.xobject(:XO1).contents,
                       [[:set_device_rgb_non_stroking_color, [1.0, 1.0, 1.0]],
                        [:append_rectangle, [0, 0, 158.0, 118.900002]],
                        [:fill_path_non_zero],
                        [:set_device_rgb_non_stroking_color, [0.0, 0.0, 0.0]],
                        [:append_rectangle, [0.0, 118.900002, 4.0, -100.0]],
                        [:append_rectangle, [6.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [12.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [22.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [28.0, 118.900002, 8.0, -100.0]],
                        [:append_rectangle, [38.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [44.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [48.0, 118.900002, 4.0, -100.0]],
                        [:append_rectangle, [56.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [66.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [70.0, 118.900002, 8.0, -100.0]],
                        [:append_rectangle, [82.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [88.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [94.0, 118.900002, 8.0, -100.0]],
                        [:append_rectangle, [104.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [110.0, 118.900002, 8.0, -100.0]],
                        [:append_rectangle, [122.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [126.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [132.0, 118.900002, 4.0, -100.0]],
                        [:append_rectangle, [142.0, 118.900002, 6.0, -100.0]],
                        [:append_rectangle, [150.0, 118.900002, 2.0, -100.0]],
                        [:append_rectangle, [154.0, 118.900002, 4.0, -100.0]],
                        [:fill_path_non_zero],
                        [:set_font_and_size, [:F1, 14.0]],
                        [:set_device_gray_non_stroking_color, [0.0]],
                        [:begin_text],
                        [:move_text, [67.716, 3.5]],
                        [:show_text, ["test"]],
                        [:end_text]])
    end

    it "supports all string alignments" do
      @obj.configure(value: '1123456', width: 50, symbology: :upce)
      @obj.draw(@canvas)
      assert_operators(@canvas.context.resources.xobject(:XO1).contents,
                       [[:set_device_rgb_non_stroking_color, [1.0, 1.0, 1.0]],
                        [:append_rectangle, [0, 0, 134.0, 116.400002]],
                        [:fill_path_non_zero],
                        [:set_device_rgb_non_stroking_color, [0.0, 0.0, 0.0]],
                        [:append_rectangle, [18.0, 116.400002, 2.0, -110.0]],
                        [:append_rectangle, [22.0, 116.400002, 2.0, -110.0]],
                        [:append_rectangle, [28.0, 116.400002, 4.0, -100.0]],
                        [:append_rectangle, [36.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [42.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [48.0, 116.400002, 4.0, -100.0]],
                        [:append_rectangle, [54.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [64.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [70.0, 116.400002, 6.0, -100.0]],
                        [:append_rectangle, [78.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [82.0, 116.400002, 4.0, -100.0]],
                        [:append_rectangle, [92.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [102.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [106.0, 116.400002, 2.0, -100.0]],
                        [:append_rectangle, [110.0, 116.400002, 2.0, -110.0]],
                        [:append_rectangle, [114.0, 116.400002, 2.0, -110.0]],
                        [:append_rectangle, [118.0, 116.400002, 2.0, -110.0]],
                        [:fill_path_non_zero],
                        [:set_font_and_size, [:F1, 14.0]],
                        [:set_device_gray_non_stroking_color, [0.0]],
                        [:begin_text],
                        [:move_text, [0.216, 0.400002]],
                        [:show_text, ["1"]],
                        [:set_font_and_size, [:F1, 20.0]],
                        [:move_text, [32.424, 0]],
                        [:show_text, ["123456"]],
                        [:set_font_and_size, [:F1, 14.0]],
                        [:move_text, [93.36, 0]],
                        [:show_text, ["2"]],
                        [:end_text]])
    end

    it "supports dotty mode" do
      @obj.configure(value: 't', width: 50, symbology: :datamatrix, output_options: 0x0100)
      @obj.draw(@canvas)
      form_contents = @canvas.context.resources.xobject(:XO1).contents
      assert_operators(form_contents,
                       [[:set_device_rgb_non_stroking_color, [1.0, 1.0, 1.0]],
                        [:append_rectangle, [0, 0, 20, 20]],
                        [:fill_path_non_zero],
                        [:set_device_rgb_non_stroking_color, [0.0, 0.0, 0.0]],
                        [:move_to, [1.8, 19.0]],
                        [:curve_to, [1.8, 19.285458, 1.647214, 19.550091, 1.4, 19.69282]],
                        [:curve_to, [1.152786, 19.835549, 0.847214, 19.835549, 0.6, 19.69282]],
                        [:curve_to, [0.352786, 19.550091, 0.2, 19.285458, 0.2, 19.0]],
                        [:curve_to, [0.2, 18.714542, 0.352786, 18.449909, 0.6, 18.30718]],
                        [:curve_to, [0.847214, 18.164451, 1.152786, 18.164451, 1.4, 18.30718]],
                        [:curve_to, [1.647214, 18.449909, 1.8, 18.714542, 1.8, 19.0]],
                        [:close_subpath],
                        [:move_to, [5.8, 19]]], range: 0..12)
      assert_operators(form_contents,
                       [[:move_to, [19.8, 1.0]],
                        [:curve_to, [19.8, 1.285458, 19.647214, 1.550091, 19.4, 1.69282]],
                        [:curve_to, [19.152786, 1.835549, 18.847214, 1.835549, 18.6, 1.69282]],
                        [:curve_to, [18.352786, 1.550091, 18.2, 1.285458, 18.2, 1.0]],
                        [:curve_to, [18.2, 0.714542, 18.352786, 0.449909, 18.6, 0.30718]],
                        [:curve_to, [18.847214, 0.164451, 19.152786, 0.164451, 19.4, 0.30718]],
                        [:curve_to, [19.647214, 0.449909, 19.8, 0.714542, 19.8, 1.0]],
                        [:close_subpath],
                        [:fill_path_non_zero]], range: -9..-1)
    end
  end
end
