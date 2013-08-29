/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
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

#import "ccTypes.h"

@class CCGLProgram;

/**
 3D grid implementation. Each vertex has 3 dimensions: x,y,z
 */
@interface CCPageGrid : NSObject
{
	GLvoid		*_texCoordinates;
	GLvoid		*_vertices;
	GLvoid		*_originalVertices;
	GLushort	*_indices;

	BOOL		_active;
	CGSize		_gridSize;
	CGPoint		_step;

	CCGLProgram	*_shaderProgram;
}

/** returns the vertex at a given position */
-(ccVertex3F)vertex:(CGPoint)pos;
/** returns the original (non-transformed) vertex at a given position */
-(ccVertex3F)originalVertex:(CGPoint)pos;
/** sets a new vertex at a given position */
-(void)setVertex:(CGPoint)pos vertex:(ccVertex3F)vertex;

/** whether or not the grid is active */
@property (nonatomic,readwrite) BOOL active;

+(id) gridWithSize:(CGSize)gridSize
      verticeCount:(CGSize)verticeCount;
-(id) initWithSize:(CGSize)gridSize
      verticeCount:(CGSize)verticeCount;

-(void)blit;

@end
