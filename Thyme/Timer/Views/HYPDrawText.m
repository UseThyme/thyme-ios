//
//  HYPDrawText.m
//
//
//  Created by Christoffer Winterkvist on 8/24/15.
//
//

#import "HYPDrawText.h"
@import CoreText;

#define DEFAULT_RADIUS 0
#define TEXT_COLOR [UIColor whiteColor]
#define TEXT_FONT [HYPUtils avenirLightWithSize:14]

typedef struct GlyphArcInfo {
    CGFloat			width;
    CGFloat			angle;	// in radians
} GlyphArcInfo;

static void PrepareGlyphArcInfo(CTLineRef line, CFIndex glyphCount, GlyphArcInfo *glyphArcInfo)
{
    NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);

    // Examine each run in the line, updating glyphOffset to track how far along the run is in terms of glyphCount.
    CFIndex glyphOffset = 0;
    for (id run in runArray) {
        CFIndex runGlyphCount = CTRunGetGlyphCount((__bridge CTRunRef)run);

        // Ask for the width of each glyph in turn.
        CFIndex runGlyphIndex = 0;
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            glyphArcInfo[runGlyphIndex + glyphOffset].width = CTRunGetTypographicBounds((__bridge CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
        }

        glyphOffset += runGlyphCount;
    }

    double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);

    CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
    glyphArcInfo[0].angle = (prevHalfWidth / lineLength) * M_PI;

    // Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
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
    // Draw a white background
    //[[UIColor greenColor] set];
    //CGContextFillRect(context, rect);

    // Initialize the text matrix to a known value
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

    // Move the origin from the lower left of the view nearer to its center.
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMidX(rect), CGRectGetMidY(rect) - DEFAULT_RADIUS / 2.0);

    // Rotate the context 90 degrees counterclockwise.
    CGContextRotateCTM(context, M_PI_2);

    /*
     Now for the actual drawing. The angle offset for each glyph relative to the previous glyph has already been calculated; with that information in hand, draw those glyphs overstruck and centered over one another, making sure to rotate the context after each glyph so the glyphs are spread along a semicircular path.
     */
    CGPoint textPosition = CGPointMake(0.0, DEFAULT_RADIUS);
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

            // Center this glyph by moving left by half its width.
            CGFloat glyphWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
            CGFloat halfGlyphWidth = glyphWidth / 2.0;

            CGFloat offset = [HYPDrawText curvedTextBottomMargin];

            CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y + offset);

            // Glyphs are positioned relative to the text position for the line, so offset text position leftwards by this glyph's width in preparation for the next glyph.
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

+ (CGFloat)curvedTextBottomMargin
{
  CGRect bounds = [[UIScreen mainScreen] bounds];
  CGFloat deviceHeight = bounds.size.height;
  CGFloat offset;

  if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
    offset = 210.0f;
  } else {
    if (deviceHeight == 480.0f) {
      offset = 140.0f;
    } else if (deviceHeight == 568.0f) {
      offset = 140.0f;
    } else if (deviceHeight == 667.0f) {
      offset = 163.0f;
    } else {
      offset = 182.0f;
    }
  }

  return offset;
}

@end
