/*
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011-2012 Zynga Inc.
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

// Simple Scene that let's you choose between 2 characters:
//   * Monus
//   * Sapus
// It performs a simple animation when each character is selected

#import "SelectCharNode.h"
#import "MainMenuNode.h"
#import "LoadingBarNode.h"
#import "SoundMenuItem.h"
#import "GameNode.h"

// CocosDenshion
#import "SimpleAudioEngine.h"

enum  {
	kTagBatchNode,
};

static int _selectedChar = kSTSelectedCharSapus;

@interface SelectCharNode (Private)
-(void) initBackground;
-(void) initChars;
-(void) initMenu;
@end

@implementation SelectCharNode
+(id) scene {
	CCScene *s = [CCScene node];
	id node = [SelectCharNode node];
	[s addChild:node];
	return s;
}

+(int) selectedChar
{
	return _selectedChar;
}

-(id) init
{
	if( (self=[super init] )) {
	
#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		[self initBackground];
		[self initChars];
		[self initMenu];
	}
	
	return self;
}

-(void) initBackground
{
	// background
	CCSprite *back = [CCSprite spriteWithFile:@"SapusChoosePlayer.png"];
	back.anchorPoint = CGPointZero;
	[self addChild:back z:-1];
}

-(void) initChars
{
	// TIP:
	// When possible try to put all your images in 1 single big image
	// It reduces loading times and memory consuption. And if you render them using SpriteSheet, it also improves the performance
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sapus-monus-selection.plist"];
	
	
	// TIP:
	// Although it is not important to use SpriteSheet in this Scene (performance is not important in this particular scene)
	// an SpriteSheet is used as an example

	
	// TIP:
	// In order to use an CCSpriteBatchNode, both the CCSpriteBatchNode and the CCSprite SHOULD share the same texture id
		
	// CCSpriteBatchNode: Loading  it with the image "sapus-monus-selection.png"
	CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"sapus-monus-selection.png" capacity:2];
	[self addChild:batch z:0 tag:kTagBatchNode];

	
	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	CCAnimationCache *animCache = [CCAnimationCache sharedAnimationCache];

	CGSize s = [[CCDirector sharedDirector] winSize];

	// TIP:
	// SpriteSheet: The sprites are also loaded from the "sapus-monus-selection.png"
	// SpriteSheet: These are SpriteFrame names that were defined in the file "sapus-monus-selection.plist"
	sapusSprite_ = [[CCSprite alloc] initWithSpriteFrameName:@"SapusSelected1.png"];
	monusSprite_ = [[CCSprite alloc] initWithSpriteFrameName:@"MonusSelected1.png"];
	
	CCAnimation *sapusAnim = [CCAnimation animationWithSpriteFrames:nil delay:0.3f];
	[sapusAnim addSpriteFrame:[frameCache spriteFrameByName:@"SapusSelected1.png"]];
	[sapusAnim addSpriteFrame:[frameCache spriteFrameByName:@"SapusSelected2.png"]];
	[animCache addAnimation:sapusAnim name:@"sapus-anim"];


	CCAnimation *sapusDefault = [CCAnimation animationWithSpriteFrames:nil delay:0.3f];
	[sapusDefault addSpriteFrame:[frameCache spriteFrameByName:@"SapusUnselected.png"]];
	[animCache addAnimation:sapusDefault name:@"sapus-default"];


	CCAnimation *monusAnim = [CCAnimation animationWithSpriteFrames:nil delay:0.3f];
	[monusAnim addSpriteFrame:[frameCache spriteFrameByName:@"MonusSelected1.png"]];
	[monusAnim addSpriteFrame:[frameCache spriteFrameByName:@"MonusSelected2.png"]];
	[animCache addAnimation:monusAnim name:@"monus-anim"];

	CCAnimation * monusDefault = [CCAnimation animationWithSpriteFrames:nil delay:0.3f];
	[monusDefault addSpriteFrame:[frameCache spriteFrameByName:@"MonusUnselected.png"]];
	[animCache addAnimation:monusDefault name:@"monus-default"];
	
	sapusSprite_.position = ccp(s.width/5,s.height/2+20);
	monusSprite_.position = ccp(4*s.width/5,s.height/2+20);
	
	// TIP BatchNode: Add Monus and Sapus to the SpriteSheet
	//		If the Sprites are added to a "normal" sprite (instead of CCSpriteBatchNode)
	//		then the sprites won't be batched (the render performance will be slower).
	[batch addChild:sapusSprite_];
	[batch addChild:monusSprite_];
}

-(void) initMenu
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	startButton_ = [[SoundMenuItem alloc] initWithNormalSpriteFrameName:@"btn-start-normal.png" selectedSpriteFrameName:@"btn-start-selected.png" target:self selector:@selector(startCallback:)];

	CCMenu	*menu = [CCMenu menuWithItems: startButton_, nil];
	startButton_.isEnabled = NO;
	startButton_.visible = NO;
	[self addChild: menu];
	
	menu.position = ccp(s.width/2,s.height/5);

}

-(void) dealloc
{
	[sapusSprite_ release];
	[monusSprite_ release];
	
	[startButton_ release];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"sapus-monus-selection.plist"];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];

	[super dealloc];	
}

// callbacks
-(void) startCallback: (id) sender 
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	LoadingBarNode *bar = [LoadingBarNode node];
	[self addChild:bar z:10];
	[bar setPosition:ccp(s.width/2, 35)];
	[bar loadImagesWithArray:[GameNode textureNames] target:self selector:@selector(imagesLoaded:)];
}

-(void) imagesLoaded:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameNode scene]]];
}

#ifdef __CC_PLATFORM_IOS

#pragma mark SelectCharNode - iPhone Touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	CCAnimation *animation = nil;

	UITouch *touch = [touches anyObject];
	if( touch ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL:location];

		if( location.x < s.width/2 && location.y < s.height-50 ) {
			_selectedChar = kSTSelectedCharSapus;
			animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"sapus-anim"];
			[sapusSprite_ runAction: [CCAnimate actionWithAnimation: animation]];
			[monusSprite_ setDisplayFrameWithAnimationName:@"monus-default" index:0];
			[[SimpleAudioEngine sharedEngine] playEffect:@"snd-select-sapus-burp.caf"];
			
			startButton_.isEnabled = YES;
			startButton_.visible = YES;

		} else if( location.x > s.width/2 && location.y < s.height-50) {
			_selectedChar = kSTSelectedCharMonus;
			animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"monus-anim"];
			[monusSprite_ runAction: [CCAnimate actionWithAnimation: animation]];
			[sapusSprite_ setDisplayFrameWithAnimationName:@"sapus-default" index:0];
			[[SimpleAudioEngine sharedEngine] playEffect:@"snd-select-monus.caf"];

			startButton_.isEnabled = YES;
			startButton_.visible = YES;

		}
	}
}

#elif defined(__CC_PLATFORM_MAC)

#pragma mark SelectCharNode - Mac Mouse
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	
	CCAnimation *animation = nil;
		
	if( location.x < s.width/2 && location.y < s.height-50 ) {
		_selectedChar = kSTSelectedCharSapus;
		animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"sapus-anim"];

		[sapusSprite_ runAction: [CCAnimate actionWithAnimation: animation] ];
		[monusSprite_ setDisplayFrameWithAnimationName:@"monus-default" index:0];
		[[SimpleAudioEngine sharedEngine] playEffect:@"snd-select-sapus-burp.caf"];
		
		startButton_.isEnabled = YES;
		startButton_.visible = YES;
		
	} else if( location.x > s.width/2 && location.y < s.height-50) {
		_selectedChar = kSTSelectedCharMonus;
		animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"monus-anim"];

		[monusSprite_ runAction: [CCAnimate actionWithAnimation: animation] ];
		[sapusSprite_ setDisplayFrameWithAnimationName:@"sapus-default" index:0];
		[[SimpleAudioEngine sharedEngine] playEffect:@"snd-select-monus.caf"];
		
		
		startButton_.isEnabled = YES;
		startButton_.visible = YES;
		
	}
		
	// swallow event. It won't be propagated to other event delegates
	// return NO to propagate to other delegates.
	return YES;
}

#endif
@end
