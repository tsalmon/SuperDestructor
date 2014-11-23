//
//  GameScene.h
//  SuperDestructeur
//

//  Copyright (c) 2014 Salmon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static const uint32_t missileCategory     =  0x1 << 4;
static const uint32_t EnnemymissileCategory     =  0x1 << 4;
static const uint32_t MonMissileCategory     =  0x1 << 6;

static const uint32_t shipCategory        =  0x1 << 1;
static const uint32_t EnnemyCategory      =  0x1 << 2;
static const uint32_t PlayerCategory      =  0x1 << 3;

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@end
