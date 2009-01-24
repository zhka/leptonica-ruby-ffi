require 'leptonica-ffi'

module Leptonica

    L_ROTATE_AREA_MAP = 1
    L_ROTATE_SHEAR = 2

    L_BRING_IN_WHITE = 1
    L_BRING_IN_BLACK = 2

    PIX_SRC = 0x18
    PIX_DST = 0x14
    PIX_SET = 0x1e
    PIX_CLR = 0x00
    def op_not(op)
        op ^ 0x1e
    end

    L_INSERT = 0
    L_COPY = 1
    L_CLONE = 2
    L_COPY_CLONE = 3

    L_SET_PIXELS = 1
    L_CLEAR_PIXELS = 2
    L_FLIP_PIXELS = 3

    COLOR_RED = 0
    COLOR_GREEN = 1
    COLOR_BLUE = 2
    L_ALPHA_CHANNEL = 3

    FILE_FORMAT_MAPPING =
    {
        :unknown => 0,
        :bmp => 1,
        :jfif_jpeg => 2,
        :png => 3,
        :tiff => 4,
        :tiff_packbits => 5,
        :tiff_rle => 6,
        :tiff_g3 => 7,
        :tiff_g4 => 8,
        :tiff_lzw => 9,
        :tiff_zip => 10,
        :pnm => 11,
        :ps => 12,
        :gif => 13,
        :default => 14,
    }

    SEL_TYPE_MAPPING =
    {
        :dont_care => 0,
        :hit => 1,
        :miss => 2,
    }

    class PointerClass
        attr_reader :pointer
        def initialize(pointer)
            @pointer = pointer
            ObjectSpace.define_finalizer(self, PointerClass.release(pointer, self.class))
        end

        def self.release(pointer, clazz)
            proc {|id| clazz.release(pointer)}
        end
    end

    class Pix < PointerClass
        def self.read(pix)
            pointer = LeptonicaFFI.pixRead(pix)
            Leptonica::Pix.new(pointer)
        end

        def self.create(w, h, d, xres=72, yres=72)
            pointer = LeptonicaFFI.pixCreate(w, h, d)
            LeptonicaFFI.pixSetXRes(pointer, xres)
            LeptonicaFFI.pixSetYRes(pointer, yres)
            Leptonica::Pix.new(pointer)
        end

        def initialize(pointer)
            super(pointer)
        end

        def dup
            Pix.new(LeptonicaFFI.pixCopy(nil, pointer))
        end

        def self.release(pointer)
            pix_pointer = MemoryPointer.new :pointer
            pix_pointer.put_pointer(0, pointer)
            LeptonicaFFI.pixDestroy(pix_pointer)
        end

        def write(filename, format = :tiff)
            LeptonicaFFI.pixWrite(filename, pointer, FILE_FORMAT_MAPPING[format])
        end

        def width
            LeptonicaFFI.pixGetWidth(pointer)
        end

        def height
            LeptonicaFFI.pixGetHeight(pointer)
        end

        def depth
            LeptonicaFFI.pixGetDepth(pointer)
        end

        def xres
            LeptonicaFFI.pixGetXRes(pointer)
        end

        def xres=(xres)
            LeptonicaFFI.pixSetXRes(pointer, xres)
        end

        def yres
            LeptonicaFFI.pixGetYRes(pointer)
        end

        def yres=(yres)
            LeptonicaFFI.pixSetYRes(pointer, yres)
        end

        ###
        # Pixel accessors
        ###

        def [](row, col)
            pixel_pointer = MemoryPointer.new :int32
            LeptonicaFFI.pixGetPixel(pointer, col, row, pixel_pointer)
            pixel_pointer.get_int(0)
        end

        def []=(row, col, val)
            LeptonicaFFI.pixSetPixel(pointer, col, row, val)
            self
        end

        def get_rgb_component(component)
            Pix.new(LeptonicaFFI.pixGetRGBComponent(pointer, component))
        end

        ###
        # Binary Morphology
        ###

        def dilate(sel)
            Pix.new(LeptonicaFFI.pixDilate(nil, pointer, sel.pointer))
        end

        def dilate!(sel)
            LeptonicaFFI.pixDilate(pointer, pointer, sel.pointer)
            self
        end

        def erode(sel)
            Pix.new(LeptonicaFFI.pixErode(nil, pointer, sel.pointer))
        end

        def erode!(sel)
            LeptonicaFFI.pixErode(pointer, pointer, sel.pointer)
            self
        end

        def open(sel)
            Pix.new(LeptonicaFFI.pixOpen(nil, pointer, sel.pointer))
        end

        def open!(sel)
            LeptonicaFFI.pixOpen(pointer, pointer, sel.pointer)
            self
        end

        def close(sel)
            Pix.new(LeptonicaFFI.pixClose(nil, pointer, sel.pointer))
        end

        def close!(sel)
            LeptonicaFFI.pixClose(pointer, pointer, sel.pointer)
            self
        end

        def hmt(sel)
            Pix.new(LeptonicaFFI.pixHMT(nil, pointer, sel.pointer))
        end

        def hmt!(sel)
            LeptonicaFFI.pixHMT(pointer, pointer, sel.pointer)
            self
        end

        ###
        # Grayscale Morphology
        ###

        def dilate_gray(width, height)
            Pix.new(LeptonicaFFI.pixDilateGray(pointer, width, height))
        end

        def erode_gray(width, height)
            Pix.new(LeptonicaFFI.pixErodeGray(pointer, width, height))
        end

        def open_gray(width, height)
            Pix.new(LeptonicaFFI.pixOpenGray(pointer, width, height))
        end

        def close_gray(width, height)
            Pix.new(LeptonicaFFI.pixCloseGray(pointer, width, height))
        end

        ###
        # Binary Operations
        ###

        def invert
            Pix.new(LeptonicaFFI.pixInvert(nil, pointer))
        end

        def invert!
            LeptonicaFFI.pixInvert(pointer, pointer)
            self
        end
        
        def and(other)
            Pix.new(LeptonicaFFI.pixAnd(nil, pointer, other.pointer))
        end
        
        def and!(other)
            LeptonicaFFI.pixAnd(pointer, pointer, other.pointer)
            self
        end
        
        def or(other)
            Pix.new(LeptonicaFFI.pixOr(nil, pointer, other.pointer))
        end
        
        def or!(other)
            LeptonicaFFI.pixOr(pointer, pointer, other.pointer)
            self
        end
        
        def xor(other)
            Pix.new(LeptonicaFFI.pixXor(nil, pointer, other.pointer))
        end
        
        def xor!(other)
            LeptonicaFFI.pixXor(pointer, pointer, other.pointer)
            self
        end
        
        def subtract(other)
            Pix.new(LeptonicaFFI.pixSubtract(nil, pointer, other.pointer))
        end
        
        def subtract!(other)
            LeptonicaFFI.pixSubtract(pointer, pointer, other.pointer)
            self
        end

        def count_pixels
            int_p = MemoryPointer.new :int32
            LeptonicaFFI.pixCountPixels(pointer, int_p, nil)
            int_p.get_int32(0)
        end

        ###
        # Threshold
        ###

        def threshold(threshold)
            Pix.new(LeptonicaFFI.pixConvertTo1(pointer, threshold))
        end

        def estimate_global_threshold
            threshold_pointer = MemoryPointer.new :int32
            LeptonicaFFI.pixSplitDistributionFgBg(pointer, 0.5, 1, threshold_pointer, nil, nil, 0)
            threshold_pointer.get_int32(0)
        end

        def rgb_to_gray
            Pix.new(LeptonicaFFI.pixConvertRGBToLuminance(pointer))
        end

        ###
        # Skew
        ###

        def deskew
            Pix.new(LeptonicaFFI.pixDeskew(pointer, 2))
        end

        def find_skew
            skew_pointer = MemoryPointer.new :float
            confidence_pointer = MemoryPointer.new :float
            LeptonicaFFI.pixFindSkew(pointer, skew_pointer, confidence_pointer)
            skew_pointer.get_float32(0)
        end

        ###
        # Rotation
        ###

        def rotate(angle, type = L_ROTATE_AREA_MAP, incolor = L_BRING_IN_WHITE)
            Pix.new(LeptonicaFFI.pixRotate(pointer, angle, type, incolor, 0, 0))
        end

        def rotate_orth(n)
            Pix.new(LeptonicaFFI.pixRotateOrth(pointer, n))
        end

        ###
        # Convolution
        ###

        def block_conv(width, height)
            Pix.new(LeptonicaFFI.pixBlockconv(pointer, width, height))
        end

        ###
        # Clipping
        ###

        def clip(box)
            Pix.new(LeptonicaFFI.pixClipRectangle(pointer, box.pointer, nil))
        end

        def crop(x, y, w, h)
            box = Box.create(x, y, w, h)
            clip(box)
        end

        ###
        # Borders
        ###

        def add_border(left, right, top, bottom, val=0)
            Pix.new(LeptonicaFFI.pixAddBorderGeneral(pointer, left, right, top, bottom, val))
        end

        def remove_border(left, right, top, bottom)
            Pix.new(LeptonicaFFI.pixRemoveBorderGeneral(pointer, left, right, top, bottom))
        end

        def set_border!(left, right, top, bottom)
            LeptonicaFFI.pixSetOrClearBorder(pointer, left, right, top, bottom, PIX_SET)
            self
        end

        def clear_border!(left, right, top, bottom)
            LeptonicaFFI.pixSetOrClearBorder(pointer, left, right, top, bottom, PIX_CLEAR)
            self
        end

        ###
        # Adaptive Maps
        ###

        def background_norm_gray_morph(reduction, sel_size, target_threshold)
            map_pointer = MemoryPointer.new :pointer
            LeptonicaFFI.pixBackgroundNormGrayArrayMorph(pointer, nil, reduction, sel_size, target_threshold, map_pointer)
            Pix.new(map_pointer.get_pointer(0))
        end

        def apply_inv_background_gray_map(map, reduction)
            Pix.new(LeptonicaFFI.pixApplyInvBackgroundGrayMap(pointer, map.pointer, reduction, reduction))
        end

        ###
        # Seed fill
        ###

        def remove_border_components(connectivity = 8)
            Pix.new(LeptonicaFFI.pixRemoveBorderConnComps(pointer, connectivity))
        end

        def holes_by_filling(connectivity = 8)
            Pix.new(LeptonicaFFI.pixHolesByFilling(pointer, connectivity))
        end

        ###
        # Connected Components
        ###

        def connected_components(connectivity = 4)
            BoxA.new(LeptonicaFFI::pixConnComp(pointer, nil, connectivity))
        end

        def count_connected_components(connectivity = 4)
            count_pointer = MemoryPointer.new :int32
            LeptonicaFFI.pixCountConnComp(pointer, connectivity, count_pointer)
            count_pointer.get_int32(0)
        end

        ###
        # Rasterops
        ###

        def shift!(dx, dy, incolor=L_BRING_IN_WHITE)
            LeptonicaFFI.pixRasteropIP(pointer, dx, dy, incolor)
            self
        end

        def self.rasterop(dest, dx, dy, dw, dh, op, source, sx, sy)
            LeptonicaFFI.pixRasterop(dest.pointer, dx, dy, dw, dh, op, source.pointer, sx, sy)
        end

        ###
        # Sel
        ###

        def to_sel(cx, cy, name = nil)
            Sel.new(LeptonicaFFI.selCreateFromPix(pointer, cx, cy, name))
        end

        ###
        # Box
        ###

        def render_box!(box, width = 1, mode = L_FLIP_PIXELS)
            LeptonicaFFI.pixRenderBox(pointer, box.pointer, width, mode)
            self
        end

        def clear_box!(box)
            LeptonicaFFI.pixClearInRect(pointer, box.pointer)
            self
        end

        ###
        # NumA
        ###

        def count_pixels_by_row
            NumA.new(LeptonicaFFI.pixCountPixelsByRow(pointer, nil))
        end

        ###
        # Graphics
        ###

        def draw_line(x1, y1, x2, y2, width = 2)
            pta = LeptonicaFFI.generatePtaWideLine(x1, y1, x2, y2, width)
            LeptonicaFFI.pixRenderPta(pointer, pta, L_SET_PIXELS)
        end

        ###
        # Morph app
        ###

        def remove_matched_pattern!(pattern, erosion, cx, cy, pixels_to_remove=1)
            LeptonicaFFI.pixRemoveMatchedPattern(pointer, pattern.pointer, erosion.pointer, cx, cy, pixels_to_remove)
            self
        end

        ###
        # Scale
        ###

        def scale_2x
            Pix.new(LeptonicaFFI.pixScaleGray2xLI(pointer))
        end

        ###
        # Enhance
        ###

        def unsharp_mask(smooth=3, frac=0.5)
            Pix.new(LeptonicaFFI.pixUnsharpMasking(pointer, smooth, frac))
        end
    end

    class Sel < PointerClass
        def self.create_empty(height, width, name = nil)
            Sel.new(LeptonicaFFI.selCreate(height, width, name))
        end

        def self.create_brick(height, width, cy = 0, cx = 0, type = :hit)
            Sel.new(LeptonicaFFI.selCreateBrick(height, width, cy, cx, SEL_TYPE_MAPPING[type]))
        end

        def self.generate_sel_with_runs(pix, nhlines, nvlines, distance, minlength, toppix, botpix, leftpix, rightpix)
            Sel.new(
                LeptonicaFFI.pixGenerateSelWithRuns(
                    pix.pointer,
                    nhlines,
                    nvlines,
                    distance,
                    minlength,
                    toppix,
                    botpix,
                    leftpix,
                    rightpix,
                    nil))
        end

        def self.generate_sel_with_runs2(pix, nhlines, nvlines, distance, minlength, toppix, botpix, leftpix, rightpix)
            expanded_pix_pointer = MemoryPointer.new :pointer
            sel = Sel.new(
                LeptonicaFFI.pixGenerateSelWithRuns(
                    pix.pointer,
                    nhlines,
                    nvlines,
                    distance,
                    minlength,
                    toppix,
                    botpix,
                    leftpix,
                    rightpix,
                    expanded_pix_pointer))
            [sel, Pix.new(expanded_pix_pointer.get_pointer(0))]
        end

        def self.release(pointer)
            sel_pointer = MemoryPointer.new :pointer
            sel_pointer.put_pointer(0, pointer)
            LeptonicaFFI.selDestroy(sel_pointer)
        end

        def initialize(pointer)
            super(pointer)
        end

        def set_origin(y, x)
            LeptonicaFFI.selSetOrigin(pointer, y, x)
        end

        def height
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, int_pointer, nil, nil, nil)
            int_pointer.get_int32(0)
        end

        def width
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, nil, int_pointer, nil, nil)
            int_pointer.get_int32(0)
        end

        def cy
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, nil, nil, int_pointer, nil)
            int_pointer.get_int32(0)
        end

        def cx
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.selGetParameters(pointer, nil, nil, nil, int_pointer)
            int_pointer.get_int32(0)
        end

        def rotate_orth(n)
            Sel.new(LeptonicaFFI.selRotateOrth(pointer, n))
        end

        def hit_miss_sel_to_pix(pix, hit_color = 0xff880000, miss_color = 0x00ff8800, scale = 0)
            Pix.new(LeptonicaFFI.pixDisplayHitMissSel(pix.pointer, pointer, scale, hit_color, miss_color))
        end

        def []=(row, col, val)
            LeptonicaFFI.selSetElement(pointer, row, col, SEL_TYPE_MAPPING[val])
        end
    end

    class Box < PointerClass
        def self.create(x, y, width, height)
            Box.new(LeptonicaFFI.boxCreate(x, y, width, height))
        end

        def self.release(pointer)
            box_pointer = MemoryPointer.new :pointer
            box_pointer.put_pointer(0, pointer)
            LeptonicaFFI.boxDestroy(box_pointer)
        end

        def initialize(pointer)
            super(pointer)
        end

        def x
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, int_pointer, nil, nil, nil)
            int_pointer.get_int32(0)
        end

        def y
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, nil, int_pointer, nil, nil)
            int_pointer.get_int32(0)
        end

        def w
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, nil, nil, int_pointer, nil)
            int_pointer.get_int32(0)
        end

        def h
            int_pointer = MemoryPointer.new :int32
            LeptonicaFFI.boxGetGeometry(pointer, nil, nil, nil, int_pointer)
            int_pointer.get_int32(0)
        end
    end

    class BoxA < PointerClass
        def initialize(pointer)
            super(pointer)
        end

        def self.release(pointer)
            boxa_pointer = MemoryPointer.new :pointer
            boxa_pointer.put_pointer(0, pointer)
            LeptonicaFFI.boxaDestroy(boxa_pointer)
        end

        def extent
            box_pointer = MemoryPointer.new :pointer
            boxa = LeptonicaFFI.boxaGetExtent(pointer, nil, nil, box_pointer)
            bounding_box = Leptonica::Box.new(box_pointer.get_pointer(0))
        end

        def each
            count.times do |i|
                yield self[i]
            end
        end

        def count
            LeptonicaFFI.boxaGetCount(pointer)
        end

        def [](index)
            Box.new(LeptonicaFFI.boxaGetBox(pointer, index, L_COPY))
        end
    end

    class NumA < PointerClass
        def initialize(pointer)
            super(pointer)
        end

        def self.release(pointer)
            numa_pointer = MemoryPointer.new :pointer
            numa_pointer.put_pointer(0, pointer)
            LeptonicaFFI.numaDestroy(numa_pointer)
        end

        def self.create(size)
            NumA.new(LeptonicaFFI.numaCreate(size))
        end

        def self.create_from_int_array(pointer, size)
            NumA.new(LeptonicaFFI.numaCreateFromIArray(pointer, size))
        end

        def find_peaks(max_peaks = 1000, min_frac = 0.5, min_slope = 1.0)
            NumA.new(LeptonicaFFI.numaFindPeaks(pointer, max_peaks, min_frac, min_slope))
        end

        def each
            count.times do |i|
                yield self[i]
            end
        end

        def get_float(index)
            f_pointer = MemoryPointer.new :float
            LeptonicaFFI.numaGetFValue(pointer, index, f_pointer)
            f_pointer.get_float32(0)
        end

        def count
            LeptonicaFFI.numaGetCount(pointer)
        end

        def [](index)
            self.get_float(index)
        end
    end
end
