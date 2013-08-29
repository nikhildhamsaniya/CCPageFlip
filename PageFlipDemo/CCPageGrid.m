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


#import "ccMacros.h"
#import "CCPageGrid.h"
#import "CCGLProgram.h"
#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCFileUtils.h"
#import "CCGLProgram.h"

#import "CCGL.h"
#import "CGPointExtension.h"
#import "ccUtils.h"
#import "TransformUtils.h"
#import "OpenGL_Internal.h"

#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"

#pragma mark -
#pragma mark CCGridBase

@implementation CCPageGrid

+(id) gridWithSize:(CGSize)gridSize
      verticeCount:(CGSize)verticeCount
{
	return [[(CCPageGrid*)[self alloc] initWithSize:gridSize verticeCount:verticeCount] autorelease];
}

-(id) initWithSize:(CGSize)gridSize
      verticeCount:(CGSize)verticeCount
{
	if( (self=[super init]) ) {

		_active = NO;
		_gridSize = verticeCount;
        _step = CGPointMake((gridSize.width) / (verticeCount.width - 1),
                            (gridSize.height) / (verticeCount.height - 1));

        //
        // Shader
        //

        NSString *fragmentFilename = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"ccShader_Grid_frag.glsl"];
        NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentFilename encoding:NSASCIIStringEncoding error:nil];
        const char *fragmentShader = [fragmentShaderString UTF8String];
        NSString *vertexFilename = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"ccShader_Grid_vert.glsl"];
        NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertexFilename encoding:NSASCIIStringEncoding error:nil];
        const char *vertexShader = [vertexShaderString UTF8String];

        CCGLProgram *p = [[CCGLProgram programWithVertexShaderByteArray:vertexShader
                                                fragmentShaderByteArray:fragmentShader] retain];
        [p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];

        [p link];
        [p updateUniforms];

        CHECK_GL_ERROR_DEBUG();

        [[CCShaderCache sharedShaderCache] addProgram:p forKey:@"ccPageGrid"];
		_shaderProgram = p;

		[self calculateVertexPoints];
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Dimensions = %ldx%ld>", [self class], self, (long)_gridSize.width, (long)_gridSize.height];
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

    [_shaderProgram release];
	free(_texCoordinates);
	free(_vertices);
	free(_indices);
	free(_originalVertices);

	[super dealloc];
}

-(void)blit
{
	NSInteger n = _gridSize.width * _gridSize.height;

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
	[_shaderProgram use];
	[_shaderProgram setUniformsForBuiltins];

	//
	// Attributes
	//

	// position
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, _vertices);

	// texCoods
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, _texCoordinates);

	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, _indices);


	CC_INCREMENT_GL_DRAWS(1);
}

-(void)calculateVertexPoints
{
	int x, y, i;

	if (_vertices) free(_vertices);
	if (_originalVertices) free(_originalVertices);
	if (_texCoordinates) free(_texCoordinates);
	if (_indices) free(_indices);
	
	NSUInteger numOfPoints = (_gridSize.width+1) * (_gridSize.height+1);
	
	_vertices = malloc(numOfPoints * sizeof(ccVertex3F));
	_originalVertices = malloc(numOfPoints * sizeof(ccVertex3F));
	_texCoordinates = malloc(numOfPoints * sizeof(ccVertex2F));
	_indices = malloc( (_gridSize.width * _gridSize.height) * sizeof(GLushort)*6);

	GLfloat *vertArray = (GLfloat*)_vertices;
	GLfloat *texArray = (GLfloat*)_texCoordinates;
	GLushort *idxArray = (GLushort *)_indices;

	for( x = 0; x < _gridSize.width; x++ )
	{
		for( y = 0; y < _gridSize.height; y++ )
		{
			NSInteger idx = (y * _gridSize.width) + x;

			GLfloat x1 = x * _step.x;
			GLfloat x2 = x1 + _step.x;
			GLfloat y1 = y * _step.y;
			GLfloat y2 = y1 + _step.y;

			GLushort a = x * (_gridSize.height+1) + y;
			GLushort b = (x+1) * (_gridSize.height+1) + y;
			GLushort c = (x+1) * (_gridSize.height+1) + (y+1);
			GLushort d = x * (_gridSize.height+1) + (y+1);

			GLushort	tempidx[6] = { a, b, d, b, c, d };

			memcpy(&idxArray[6*idx], tempidx, 6*sizeof(GLushort));

			int l1[4] = { a*3, b*3, c*3, d*3 };
			ccVertex3F	e = {x1,y1,0};
			ccVertex3F	f = {x2,y1,0};
			ccVertex3F	g = {x2,y2,0};
			ccVertex3F	h = {x1,y2,0};

			ccVertex3F l2[4] = { e, f, g, h };

			int tex1[4] = { a*2, b*2, c*2, d*2 };
            float tx1 = ((float)x) / _gridSize.width;
            float tx2 = ((float)x+1) / _gridSize.width;
            float ty1 = ((float)y) / _gridSize.height;
            float ty2 = ((float)y+1) / _gridSize.height;
			CGPoint uv2[4] = { ccp(tx1, ty1), ccp(tx2, ty1), ccp(tx2, ty2), ccp(tx1, ty2) };

			for( i = 0; i < 4; i++ )
			{
				vertArray[ l1[i] ] = l2[i].x;
				vertArray[ l1[i] + 1 ] = l2[i].y;
				vertArray[ l1[i] + 2 ] = l2[i].z;

				texArray[ tex1[i] ] = uv2[i].x;
                texArray[ tex1[i] + 1 ] = uv2[i].y;
			}
		}
	}

	memcpy(_originalVertices, _vertices, (_gridSize.width+1)*(_gridSize.height+1)*sizeof(ccVertex3F));
}

-(ccVertex3F)vertex:(CGPoint)pos
{
	NSAssert( pos.x == (NSUInteger)pos.x && pos.y == (NSUInteger) pos.y , @"Numbers must be integers");

	NSInteger index = (pos.x * (_gridSize.height+1) + pos.y) * 3;
	float *vertArray = (float *)_vertices;

	ccVertex3F	vert = { vertArray[index], vertArray[index+1], vertArray[index+2] };

	return vert;
}

-(ccVertex3F)originalVertex:(CGPoint)pos
{
	NSAssert( pos.x == (NSUInteger)pos.x && pos.y == (NSUInteger) pos.y , @"Numbers must be integers");

	NSInteger index = (pos.x * (_gridSize.height+1) + pos.y) * 3;
	float *vertArray = (float *)_originalVertices;

	ccVertex3F	vert = { vertArray[index], vertArray[index+1], vertArray[index+2] };

	return vert;
}

-(void)setVertex:(CGPoint)pos vertex:(ccVertex3F)vertex
{
	NSAssert( pos.x == (NSUInteger)pos.x && pos.y == (NSUInteger) pos.y , @"Numbers must be integers");

	NSInteger index = (pos.x * (_gridSize.height+1) + pos.y) * 3;
	float *vertArray = (float *)_vertices;
	vertArray[index] = vertex.x;
	vertArray[index+1] = vertex.y;
	vertArray[index+2] = vertex.z;
}

@end
