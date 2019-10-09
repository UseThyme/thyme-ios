#import "HYPDrawText.h"
@import CoreText;

typedef struct GlyphArcInfo {
    CGFloat			width;
    CGFloat			angle;	// in radians
} GlyphArcInfo;

static void PrepareGlyphArcInfo(CTLineRef line, CFIndex glyphCount, GlyphArcInfo *glyphArcInfo)
{
    NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);

    CFIndex glyphOffset = 0;
    for (id run in runArray) {
        CFIndex runGlyphCount = CTRunGetGlyphCount((__bridge CTRunRef)run);
        CFIndex runGlyphIndex = 0;
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            glyphArcInfo[runGlyphIndex + glyphOffset].width = CTRunGetTypographicBounds((__bridge CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
        }

        glyphOffset += runGlyphCount;
    }

    double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);

    CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
    glyphArcInfo[0].angle = (prevHalfWidth / lineLength) * M_PI;

    CFIndex lineGlyphIndex = 1;
    for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
        CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
        CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;

        glyphArcInfo[lineGlyphIndex].angle = (prevCenterToCenter / lineLength) * M_PI;

        prevHalfWidth = halfWidth;
    }
}

@implementation HYPDrawText

+ (void)drawText:(CGContextRef)context rect:(CGRect)rect attributedString:(NSAttributedString *)attributedString
{
    CGAffineTransform t0 = CGContextGetCTM(context);
    CGFloat xScaleFactor = t0.a > 0 ? t0.a : -t0.a;
    CGFloat yScaleFactor = t0.d > 0 ? t0.d : -t0.d;
    t0 = CGAffineTransformInvert(t0);
    if (xScaleFactor != 1.0 || yScaleFactor != 1.0)
        t0 = CGAffineTransformScale(t0, xScaleFactor, yScaleFactor);
    CGContextConcatCTM(context, t0);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    assert(line != NULL);

    CFIndex glyphCount = CTLineGetGlyphCount(line);
    if (glyphCount == 0) {
        CFRelease(line);
        return;
    }

    GlyphArcInfo *	glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
    PrepareGlyphArcInfo(line, glyphCount, glyphArcInfo);

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMidX(rect), CGRectGetMidY(rect) - [HYPDrawText defaultRadius] / 2.0);

    CGContextRotateCTM(context, M_PI_2);
    CGPoint textPosition = CGPointMake(0.0, [HYPDrawText defaultRadius]);
    CGContextSetTextPosition(context, textPosition.x, textPosition.y);

    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runArray);

    CFIndex glyphOffset = 0;
    CFIndex runIndex = 0;
    for (; runIndex < runCount; runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CFIndex runGlyphCount = CTRunGetGlyphCount(run);

        for (CFIndex runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++) {

            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            CGContextRotateCTM(context, -(glyphArcInfo[runGlyphIndex + glyphOffset].angle));
            CGFloat glyphWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
            CGFloat halfGlyphWidth = glyphWidth / 2.0;
            CGFloat offset = [HYPDrawText curvedTextBottomMargin];
            CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y + offset);
            textPosition.x -= glyphWidth;

            CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
            textMatrix.tx = positionForThisGlyph.x;
            textMatrix.ty = positionForThisGlyph.y;
            CGContextSetTextMatrix(context, textMatrix);

            if (runGlyphIndex < 18 || runGlyphIndex > runGlyphCount - 19) {
                continue;
            }

            CTRunDraw(run, context, glyphRange);
        }

        glyphOffset += runGlyphCount;
    }

    CGContextRestoreGState(context);

    free(glyphArcInfo);
    CFRelease(line);
}

+ (CGFloat)defaultRadius
{
    return 0;
}

+ (CGFloat)curvedTextBottomMargin
{
  CGRect bounds = [[UIScreen mainScreen] bounds];
  CGFloat screenHeight = bounds.size.height;
  CGFloat offset;

  if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
    offset = 210.0f;
  } else {
    if (screenHeight == 480.0f) {
      offset = 140.0f;
    } else if (screenHeight == 568.0f) {
      offset = 140.0f;
    } else if (screenHeight == 667.0f) {
      offset = 163.0f;
    } else if (screenHeight == 736.0f) {
        offset = 182.0f;
    } else if (screenHeight == 896.0f) { // XR, XS Max
        offset = 182.0f;
    } else if (screenHeight == 812.0f) { // X, XS
        offset = 172.0f;
    } else {
      offset = 182.0f;
    }
  }

  return offset;
}

@end
