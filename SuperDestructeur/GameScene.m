//
//  GameScene.m
//  TP2
//
//  Created by Salmon on 15/11/2014.
//  Copyright (c) 2014 Salmon. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

SKSpriteNode *mon_avion;
int mon_avion_pv;
SKSpriteNode *ennemi;
SKLabelNode *informationsPlayer;
SKLabelNode *informationsEnnemi;
SKLabelNode *informationsLVL;

int difficulte_lvl = 1;
double ennemi_wait = 1.0;

int ennemi_pv;

-(void) newGame {
    for(SKNode *node in self.children){
        if(node.physicsBody.categoryBitMask == missileCategory){
            [node removeFromParent];
        }
    }
    
    mon_avion.position = CGPointMake(186, 422);

    ennemi_pv = 100;
    ennemi.position = CGPointMake(886, 422);

    informationsLVL.text = [NSString stringWithFormat:@"niveau : %d", difficulte_lvl];
    informationsEnnemi.text = [NSString stringWithFormat:@"Ennemi : 100 PV"];
    informationsPlayer.text = [NSString stringWithFormat:@"Vaisseau : %d PV", mon_avion_pv];
}


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */

    informationsLVL=  [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
    informationsLVL.fontSize = 30;
    informationsLVL.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 100);
    [self addChild:informationsLVL];

    
    informationsEnnemi =  [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
    informationsEnnemi.fontSize = 30;
    informationsEnnemi.position = CGPointMake(150, self.frame.size.height - 100);
    [self addChild:informationsEnnemi];

    informationsPlayer =  [SKLabelNode labelNodeWithFontNamed:@"TimesNewRoman"];
    informationsPlayer.fontSize = 30;
    informationsPlayer.position = CGPointMake(self.frame.size.width-150 , self.frame.size.height-100);
    [self addChild:informationsPlayer];

    
    mon_avion = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    SKAction *action = [SKAction rotateByAngle:-M_PI/2 duration:0];
    [mon_avion runAction: action];

    mon_avion.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:mon_avion.size];
    mon_avion.physicsBody.categoryBitMask = PlayerCategory  | shipCategory;
    mon_avion.physicsBody.collisionBitMask =  shipCategory;
    mon_avion.physicsBody.contactTestBitMask = shipCategory ;
    
    mon_avion.scale = 0.3;
    
    ennemi = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    action = [SKAction rotateByAngle:M_PI/2 duration:0];
    [ennemi runAction: action];

    ennemi.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ennemi.size];
    ennemi.physicsBody.categoryBitMask =  EnnemyCategory | shipCategory;
    ennemi.physicsBody.collisionBitMask = shipCategory;
    ennemi.physicsBody.contactTestBitMask =  shipCategory ;
    
    ennemi.scale = 0.3;
    SKAction *randomXMovement = [SKAction runBlock:^(void){
        if(ennemi_wait > 0.0){
            SKAction *waitLVL = [SKAction waitForDuration:ennemi_wait];
            [ennemi runAction:waitLVL];
        } else {
            NSLog(@"%f", ennemi_wait);
        }
        
        NSInteger Movement = arc4random() % (500);
        NSInteger move_dir = arc4random() % 4;
        SKAction *moving;
        if (move_dir == 0 && ennemi.position.x + Movement + 50 < (NSInteger)self.frame.size.width) {
           moving = [SKAction moveByX:Movement y:0 duration:1.0];
            [ennemi runAction:moving];
        } else if(move_dir == 1 && ennemi.position.x - Movement - 50 > self.frame.size.width/2 + 40){
            moving = [SKAction moveByX:-Movement y:0 duration:1.0];
            [ennemi runAction:moving];
        } else if(move_dir == 2 && ennemi.position.y - Movement - 50 > 0){
            moving = [SKAction moveByX:0 y:-Movement duration:1.0];
            [ennemi runAction:moving];
        } else if(move_dir == 3 && ennemi.position.y + Movement + 50 < (NSInteger)self.frame.size.height){
            moving = [SKAction moveByX:0 y:Movement duration:1.0];
            [ennemi runAction:moving];
        }
        [self tirer:ennemi];

    }];
    
    SKAction *wait = [SKAction waitForDuration:ennemi_wait];
    SKAction *sequence = [SKAction sequence:@[randomXMovement, wait]];
    SKAction *repeat = [SKAction repeatActionForever:sequence];
    
    [ennemi runAction: repeat];
    
    [self newGame];

    [self addChild:mon_avion];
    [self addChild:ennemi];

    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
}


-(void)tirer:(SKSpriteNode *)avion {
    NSInteger direction_tir = 1600;
    
    SKSpriteNode *missile = [SKSpriteNode spriteNodeWithImageNamed:@"missile"];
    
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask =  missileCategory ;
    if(avion != mon_avion){
        direction_tir *=-1;
        missile.physicsBody.categoryBitMask |= EnnemymissileCategory;
        missile.physicsBody.contactTestBitMask =  PlayerCategory;
        missile.physicsBody.collisionBitMask =  PlayerCategory;
    } else {
        missile.physicsBody.categoryBitMask |= MonMissileCategory;
        missile.physicsBody.contactTestBitMask =  EnnemyCategory;
        missile.physicsBody.collisionBitMask =  EnnemyCategory;
    }
    
    missile.position = avion.position;
    missile.scale = 0.3;
    SKAction *action = [SKAction moveToX:direction_tir duration:1.9];
    [missile runAction: action];
    [self addChild:missile];
}

-(void) message:(NSString *) message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Oui"];
    [alert addButtonWithTitle:@"Non"];
    [alert setMessageText:message];
    [alert setInformativeText:@"Voulez vous recommencer?"];
    [alert setAlertStyle:NSWarningAlertStyle];

    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self deleteRecord:true];
    } else if([alert runModal] == NSAlertSecondButtonReturn){
        [self deleteRecord:false];
    }
}

-(void) deleteRecord:(Boolean) alert_retour {
    if(alert_retour){
        mon_avion_pv = 100;
        difficulte_lvl = 1;
        [self newGame];
    } else {
        exit(0);
    }
}

-(void) didBeginContact:(SKPhysicsContact *) contact {
    uint32_t bitMaskA = contact.bodyA.categoryBitMask;
    uint32_t bitMaskB = contact.bodyB.categoryBitMask;
    
    // Check if your object have a contact
    if (((bitMaskA & shipCategory) != 0 && (bitMaskB & missileCategory)) != 0 ||
        ((bitMaskB & missileCategory) != 0 && (bitMaskA & shipCategory)) != 0)
    {
        SKPhysicsBody *avion_touche;
        SKPhysicsBody *missile;
        if ((bitMaskA & shipCategory) != 0) {
            avion_touche = contact.bodyA;
            missile = contact.bodyB;
        } else {
            missile = contact.bodyA;
            avion_touche = contact.bodyB;
        }
        
        if((avion_touche.categoryBitMask & PlayerCategory) != 0){
            [self touche:mon_avion];
            mon_avion_pv-=20 + (0.5*(difficulte_lvl - 1));
            informationsPlayer.text =  [NSString stringWithFormat:@"Vaisseau : %d PV", mon_avion_pv];
            if(mon_avion_pv <= 0){
                [self message:@"Vous avez perdu"];
            }
            [missile.node removeFromParent];
        } else if((avion_touche.categoryBitMask & EnnemyCategory) != 0){
            [self touche:ennemi];
            ennemi_pv-=20;
            informationsEnnemi.text =  [NSString stringWithFormat:@"Ennemi : %d PV", ennemi_pv];
            if(ennemi_pv == 0){
                difficulte_lvl++;
                [self newGame];
            }
            [missile.node removeFromParent];
        }
    }
}

- (void)keyDown:(NSEvent *)event {
    [self handleKeyEvent:event keyDown:YES];
}

- (void)handleKeyEvent:(NSEvent *)event keyDown:(BOOL)downOrUp {
    NSString *characters = [event characters];
    for (int s = 0; s<[characters length]; s++) {
        unichar oneCharacter = [characters characterAtIndex:s];
        switch (oneCharacter) {
            case NSUpArrowFunctionKey:
                if(mon_avion.position.y + 80 < (NSInteger)self.frame.size.height){
                [mon_avion runAction:[SKAction moveByX:0 y:80 duration:0.2]];
                }
                break;
            case NSLeftArrowFunctionKey:
                if(mon_avion.position.x - 80 > 0){
                    [mon_avion runAction:[SKAction moveByX:-80 y:0 duration:0.2]];
                }
                break;
            case NSRightArrowFunctionKey:
                if(mon_avion.position.x  < (NSInteger)self.frame.size.width/2 - 50){
                    [mon_avion runAction:[SKAction moveByX:80 y:0 duration:0.2]];
                }
                break;
            case NSDownArrowFunctionKey:
                if(mon_avion.position.y - 80 > 0){
                    [mon_avion runAction:[SKAction moveByX:0 y:-80 duration:0.2]];
                }
                break;
            case 32:
                [self tirer:mon_avion];
                break;
        }
    }
}

-(void) touche: (SKSpriteNode *)avion {
    SKAction *pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
                                              [SKAction waitForDuration:0.1],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
    [avion runAction:pulseRed];
}

-(void) didSimulatePhysics{
    for(SKNode *node in self.children){
        if(node.position.y < -20 ||
           node.position.x < -20 ||
           node.position.y > (NSInteger)self.frame.size.height + 20 ||
            node.position.x > (NSInteger)self.frame.size.width + 20){
            if(node == mon_avion){
                [self message:@"Vous avez perdu"];
                break;
            }
            if(node == ennemi){
                [self message:@"Vous avez gagné"];
                break;
            } else {
                [node removeFromParent];
            }
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
