/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Sindesso Pty Ltd http://www.sindesso.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

/*
#import "CCActionPageTurn3D.h"
#import "Support/CGPointExtension.h"

static inline CGFloat lerp(CGFloat ft, CGFloat f0, CGFloat f1)
{
    // Linear interpolation between f0 and f1
	return f0 + (f1 - f0) * ft;
}

@implementation CCPageTurn3D

- (void)configureTurn:(ccTime)t
{
    float RAD = (180.0f / M_PI);
    // This method computes rho, theta, and A for time parameter t using pre-defined functions to simulate a natural page turn
    // without finger tracking, i.e., for a quick swipe of the finger to turn to the next page.
    // These functions were constructed empirically by breaking down a page turn into phases and experimenting with trial and error
    // until we got acceptable results. This basic example consists of three distinct phases, but a more elegant solution yielding
    // smoother transitions can be obtained by curve fitting functions to our key data points once satisfied with the behavior.
    CGFloat angle1 =  90.0f / RAD;  //  }
    CGFloat angle2 =   8.0f / RAD;  //  }
    CGFloat angle3 =   6.0f / RAD;  //  }
    CGFloat     A1 = -1500.0f;        //  }
    CGFloat     A2 =  -400.5f;        //  }--- Experiment with these parameters to adjust the page turn behavior to your liking.
    CGFloat     A3 =  -600.5f;        //  }
    CGFloat theta1 =   0.05f;       //  }
    CGFloat theta2 =   0.5f;        //  }
    CGFloat theta3 =  10.0f;        //  }
    CGFloat theta4 =   2.0f;        //  }

    CGFloat f1, f2, dt;
    float rho, theta, A;

    // Here rho, the angle of the page rotation around the spine, is a linear function of time t. This is the simplest case and looks
    // Good Enough. A side effect is that due to the curling effect, the page appears to accelerate quickly at the beginning
    // of the turn, then slow down toward the end as the page uncurls and returns to its natural form, just like in real life.
    // A non-linear function may be slightly more realistic but is beyond the scope of this example.
    rho = t * M_PI;

    if (t <= 0.15f) {
        // Start off with a flat page with no deformation at the beginning of a page turn, then begin to curl the page gradually
        // as the hand lifts it off the surface of the book.
        dt = t / 0.15;
        f1 = sin(M_PI * pow(dt, theta1) / 2.0);
        f2 = sin(M_PI * pow(dt, theta2) / 2.0);
        theta = lerp(f1, angle1, angle2);
        A = lerp(f2, A1, A2);
    } else if (t <= 0.4) {
        // Produce the most pronounced curling near the middle of the turn. Here small values of theta and A
        // result in a short, fat cone that distinctly show the curl effect.
        dt = (t - 0.15) / 0.25;
        theta = lerp(dt, angle2, angle3);
        A = lerp(dt, A2, A3);
    } else if (t <= 1.0) {
        // Near the middle of the turn, the hand has released the page so it can return to its normal form.
        // Ease out the curl until it returns to a flat page at the completion of the turn. More advanced simulations
        // could apply a slight wobble to the page as it falls down like in real life.
        dt = (t - 0.4) / 0.6;
        f1 = sin(M_PI * pow(dt, theta3) / 2.0);
        f2 = sin(M_PI * pow(dt, theta4) / 2.0);
        theta = lerp(f1, angle3, angle1);
        A = lerp(f2, A3, A1);
    }

    _apex = A;
    _rotation = rho;
    _theta = theta;
}


// Update each tick
// Time is the percentage of the way through the duration
//
-(void)update:(ccTime)time
{
    [self configureTurn:time];

    float theta = _theta;
    float ay = _apex;
    float rho = _rotation;

	float sinTheta = sinf(theta);
	float cosTheta = cosf(theta);

	float sinRho = sinf(rho);
	float cosRho = cosf(rho);

	for( int i = 0; i <=_gridSize.width; i++ )
	{
		for( int j = 0; j <= _gridSize.height; j++ )
		{
			// Get original vertex
			ccVertex3F	p = [self originalVertex:ccp(i,j)];

            {
                // curl the page
                float R = sqrtf(p.x*p.x + (p.y - ay) * (p.y - ay));
                float r = R * sinTheta;
                float alpha = asinf( p.x / R );
                float beta = alpha / sinTheta;
                float cosBeta = cosf( beta );

                // If beta > PI then we've wrapped around the cone
                // Reduce the radius to stop these points interfering with others
                p.x = ( r * sinf(beta));
                p.y = ( R + ay - ( r*(1 - cosBeta)*sinTheta));
                p.z = r * ( 1 - cosBeta ) * cosTheta; // "100" didn't work for
            }

            {
                // Rotate
                float x = p.x;
                float z = p.z;
                p.x = (x * cosRho - z * sinRho);
                p.y = p.y;
                p.z = (x * sinRho + z * cosRho);
            }

            // Set new coords
			[self setVertex:ccp(i,j) vertex:p];
		}
	}
}
@end

*/