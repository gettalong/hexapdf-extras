require 'test_helper'
require 'hexapdf'
require 'hexapdf/extras/graphic_object/qr_code'

describe HexaPDF::Extras::GraphicObject::QRCode do
  before do
    @obj = HexaPDF::Extras::GraphicObject::QRCode.new
  end

  it "allows creation via the ::configure method" do
    obj = HexaPDF::Extras::GraphicObject::QRCode.configure(data: 'test')
    assert_equal('test', obj.data)
  end

  it "creates a default Geom2D drawing support object" do
    [:size, :light_color, :data, :code_size, :max_code_size, :level, :mode].each do |method_name|
      assert_nil(@obj.send(method_name))
    end
    assert_equal([0, 0], @obj.at)
    assert_equal('black', @obj.dark_color)
  end

  it "allows configuration of the object" do
    @obj.configure(data: 'test', size: 30)
    assert_equal('test', @obj.data)
    assert_equal(30, @obj.size)
  end

  describe "draw" do
    before do
      doc = HexaPDF::Document.new
      @canvas = doc.pages.add.canvas
    end

    it "draws a QRCode onto the canvas" do
      @obj.configure(data: 'test', size: 210)
      @obj.draw(@canvas)
      assert_operators(@canvas.contents,
                       [[:save_graphics_state],
                        [:concatenate_matrix, [1, 0, 0, 1, 0, 0]],
                        [:set_line_width, [10]],
                        [:set_device_rgb_stroking_color, [0, 0, 0]],
                        [:set_line_dash_pattern, [[70, 10, 30, 10, 10, 10, 70], 0]],
                        [:move_to, [0, 205]], [:line_to, [210, 205]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 50, 10, 10, 20, 40, 10, 50, 10], 0]],
                        [:move_to, [0, 195]], [:line_to, [210, 195]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 10, 30, 10, 10, 30, 20, 20, 10, 10, 30, 10, 10], 0]],
                        [:move_to, [0, 185]], [:line_to, [210, 185]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 10, 30, 10, 10, 10, 10, 20, 20, 10, 10, 10, 30, 10, 10], 0]],
                        [:move_to, [0, 175]], [:line_to, [210, 175]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 10, 30, 10, 10, 10, 10, 20, 10, 20, 10, 10, 30, 10, 10], 0]],
                        [:move_to, [0, 165]], [:line_to, [210, 165]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 50, 10, 10, 20, 40, 10, 50, 10], 0]],
                        [:move_to, [0, 155]], [:line_to, [210, 155]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[70, 10, 10, 10, 10, 10, 10, 10, 70], 0]],
                        [:move_to, [0, 145]], [:line_to, [210, 145]], [:stroke_path],
                        [:set_line_dash_pattern, [[0, 90, 20, 10, 10, 80], 0]],
                        [:move_to, [0, 135]], [:line_to, [210, 135]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[0, 30, 10, 20, 10, 20, 10, 10, 10, 30, 30, 10, 20], 0]],
                        [:move_to, [0, 125]], [:line_to, [210, 125]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[0, 30, 20, 20, 20, 30, 10, 10, 20, 30, 20], 0]],
                        [:move_to, [0, 115]], [:line_to, [210, 115]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 10, 20, 20, 30, 10, 10, 10, 10, 10, 50, 10, 10], 0]],
                        [:move_to, [0, 105]], [:line_to, [210, 105]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[20, 10, 10, 50, 10, 20, 10, 10, 40, 10, 20], 0]],
                        [:move_to, [0, 95]], [:line_to, [210, 95]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[20, 30, 20, 10, 30, 40, 10, 10, 10, 10, 20], 0]],
                        [:move_to, [0, 85]], [:line_to, [210, 85]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[0, 80, 10, 20, 30, 20, 20, 10, 20], 0]],
                        [:move_to, [0, 75]], [:line_to, [210, 75]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[70, 20, 30, 20, 10, 10, 10, 20, 10, 10], 0]],
                        [:move_to, [0, 65]], [:line_to, [210, 65]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 50, 10, 20, 20, 10, 10, 10, 10, 40, 10, 10], 0]],
                        [:move_to, [0, 55]], [:line_to, [210, 55]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 10, 30, 10, 10, 40, 10, 10, 20, 20, 10, 20, 10], 0]],
                        [:move_to, [0, 45]], [:line_to, [210, 45]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 10, 30, 10, 10, 10, 20, 10, 10, 30, 10, 10, 10, 10, 20], 0]],
                        [:move_to, [0, 35]], [:line_to, [210, 35]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 10, 30, 10, 10, 50, 20, 10, 10, 20, 10, 10, 10], 0]],
                        [:move_to, [0, 25]], [:line_to, [210, 25]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[10, 50, 10, 20, 10, 10, 10, 20, 20, 10, 10, 30], 0]],
                        [:move_to, [0, 15]], [:line_to, [210, 15]], [:stroke_path],
                        [:set_line_dash_pattern,
                         [[70, 30, 20, 10, 10, 10, 10, 10, 30, 10], 0]],
                        [:move_to, [0, 5]], [:line_to, [210, 5]], [:stroke_path],
                        [:restore_graphics_state]])
    end
  end
end
