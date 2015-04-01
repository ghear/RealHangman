//
//  ViewController.m
//  RealHangman
//
//  Created by Ryan Higgins on 4/1/15.
//  Copyright (c) 2015 Higgnet. All rights reserved.
//

#import "ViewController.h"
#import "HangmanWords.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImage *gallow;
@property (nonatomic, strong) UIImageView *gallowView;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) HangmanWords *wordGenerator;
@property (nonatomic, copy) NSString *secretWord;
@property (nonatomic) NSInteger wordLength;
@property (nonatomic, strong) NSMutableArray *wordLabels;
@property (nonatomic, strong) NSMutableArray *secretWordSplit;
@property (nonatomic, strong) NSMutableArray *currentWordsDisplayed;
@property (nonatomic, strong) NSMutableArray *guessedLetters;
@property (nonatomic, strong) NSMutableArray *wrongGuessedLetters;
@property (nonatomic, strong) UILabel *outcomeLabel;
@property (nonatomic) BOOL winner;
@end

@implementation ViewController

typedef enum {
    iPhone4 = 1,
    iPhone5 = 2,
    iPhone6 = 3,
} iPhoneModel;

-(instancetype)init
{
    if (self = [super init]) {
        _winner = NO;
        _wordLabels = [[NSMutableArray alloc] init];
        _secretWordSplit = [[NSMutableArray alloc] init];
        _wordGenerator = [[HangmanWords alloc] init];
        _guessedLetters = [[NSMutableArray alloc] init];
        _wrongGuessedLetters = [[NSMutableArray alloc] init];
        _currentWordsDisplayed = [[NSMutableArray alloc] init];
        
        _gallow = [UIImage imageNamed:@"gallow"];
        _gallowView = [[UIImageView alloc] initWithImage:self.gallow];
        if ([[UIScreen mainScreen] bounds].size.height > 568) {
            _gallowView.frame = CGRectMake(10, 375, 360, 200);
        } else {
            _gallowView.frame = CGRectMake(10, 275, 360, 200);
        }
        [self.view addSubview:_gallowView];
        
        _secretWord = [self.wordGenerator getWord];
        _wordLength = [self.secretWord length];
        [self drawDashes];
    }
    return self;
}
- (IBAction)resetGame:(id)sender {
    self.secretWord = [self.wordGenerator getWord];
    self.wordLength = [self.secretWord length];
    //NSLog(@"The new secret word is: %@ with a length of %lu", self.secretWord, self.wordLength);
    for (UILabel *wordLabel in self.wordLabels) {
        [wordLabel removeFromSuperview];
    }
    [self.guessedLetters removeAllObjects];
    [self.wrongGuessedLetters removeAllObjects];
    [self.wordLabels removeAllObjects];
    self.gallowView.image = [UIImage imageNamed:@"gallow"];
    [self.currentWordsDisplayed removeAllObjects];
    [self.outcomeLabel removeFromSuperview];
    self.outcomeLabel = nil;
    self.textField.enabled = YES;
    self.winner = NO;
    [self drawDashes];
}

-(void)drawDashes
{
    self.secretWordSplit = (NSMutableArray *)[self.secretWord componentsSeparatedByString:@" "];
    // Each word will be on its own line
    // Draw distinct labels equal to the number of words in wordsArray
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSUInteger wordLabelWidth = screenRect.size.width;
    for (int i = 0; i < [self.secretWordSplit count]; i++) {
        CGRect wordRect;
        if ([[UIScreen mainScreen] bounds].size.height > 568) {
            wordRect = CGRectMake(30, 80 + (i * 40), wordLabelWidth, 50);
        } else {
            wordRect = CGRectMake(30, 80 + (i * 30), wordLabelWidth, 30);
        }
        UILabel *wordLabel = [[UILabel alloc] initWithFrame:wordRect];
        NSUInteger numberOfDashes = [self.secretWordSplit[i] length];
        NSString *dashes = @"";
        for (int j = 0; j < numberOfDashes; j++) {
            dashes = [dashes stringByAppendingString:@"-"];
        }
        [self.currentWordsDisplayed addObject:dashes];
        [self.wordLabels addObject:wordLabel];
        wordLabel.text = dashes;
        if ([[UIScreen mainScreen] bounds].size.height > 568) {
            wordLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:50];
        } else {
            wordLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
        }
        [self.view addSubview:wordLabel];
    }
}

// Text Field Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 1) ? NO: YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.winner) {
        return YES;
    }
    //NSLog(@"Your guess is %@", self.textField.text);
    [self.textField resignFirstResponder];
    BOOL hasLetter = NO;
    for (int j = 0; j < [self.secretWordSplit count]; j++) {
        NSString *word = self.secretWordSplit[j];
        if ([word rangeOfString:[NSString stringWithFormat:@"%@", self.textField.text.capitalizedString]].location != NSNotFound) {
            //has guessed character
            hasLetter = YES;
            NSString *resultingWord = @"";
            for (int i = 0; i < [word length]; i++) {
                unichar letterUnichar = [word characterAtIndex:i];
                NSString *letter = [NSString stringWithFormat:@"%c", letterUnichar];
                
                
                if ([letter isEqualToString:self.textField.text.capitalizedString]) {
                    resultingWord = [resultingWord stringByAppendingString:letter];

                } else {
                    BOOL beenGuessed = NO;
                    for (int z = 0; z < [self.guessedLetters count]; z++) {
                        if ([self.guessedLetters[z] isEqualToString:letter]) {
                            resultingWord = [resultingWord stringByAppendingString:letter];
                            beenGuessed = YES;
                        }
                    }
                    if (!beenGuessed) {
                        resultingWord = [resultingWord stringByAppendingString:@"-"];
                    }
                }
            }
            

            BOOL alreadyGuessed = NO;
            for (int p = 0; p < [self.guessedLetters count]; p++) {
                if ([self.guessedLetters[p] isEqualToString:self.textField.text.capitalizedString]) {
                    alreadyGuessed = YES;
                }
            }
            if (!alreadyGuessed) {
                [self.guessedLetters addObject:self.textField.text.capitalizedString];
            }
            word = resultingWord;
            self.currentWordsDisplayed[j] = word;
            UILabel *wordLabel = self.wordLabels[j];
            wordLabel.text = word;
        }
    }
    
    if (!hasLetter) {
        BOOL alreadyWrongGuessed = NO;
        for (int q = 0; q < [self.wrongGuessedLetters count]; q++) {
            if ([self.wrongGuessedLetters[q] isEqualToString:self.textField.text.capitalizedString]) {
                alreadyWrongGuessed = YES;
            }
        }
        if (!alreadyWrongGuessed) {
            [self.wrongGuessedLetters addObject:self.textField.text.capitalizedString];
            if ([self.wrongGuessedLetters count] == 1) {
                self.gallowView.image = [UIImage imageNamed:@"gallowHead"];
            } else if ([self.wrongGuessedLetters count] == 2) {
                self.gallowView.image = [UIImage imageNamed:@"gallowBody"];
            } else if ([self.wrongGuessedLetters count] == 3) {
                self.gallowView.image = [UIImage imageNamed:@"gallowLegOne"];
            } else if ([self.wrongGuessedLetters count] == 4) {
                self.gallowView.image = [UIImage imageNamed:@"gallowLegTwo"];
            } else if ([self.wrongGuessedLetters count] == 5) {
                self.gallowView.image = [UIImage imageNamed:@"gallowArmOne"];
            } else if ([self.wrongGuessedLetters count] == 6) {
                self.gallowView.image = [UIImage imageNamed:@"gallowArmTwo"];
                [self drawDefeat];
            }
        }
    }
    
    if ([self didWin]) {
        return YES;
    }
    
    return YES;
}

-(BOOL)didWin
{
    for (int i = 0; i < [self.currentWordsDisplayed count]; i++) {
        NSString *word = self.currentWordsDisplayed[i];
        for (int j = 0; j < [word length]; j++) {
            unichar letterChar = [word characterAtIndex:j];
            NSString *letter = [NSString stringWithFormat:@"%c", letterChar];
            if ([letter isEqualToString:@"-"]) {
                //Not yet a winner
                return NO;
            }
        }
    }
    //winner
    [self drawVictory];
    self.winner = YES;
    return YES;
}

-(void)drawVictory
{
    self.textField.enabled = NO;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSUInteger wordLabelWidth = screenRect.size.width;
    CGRect victoryRect = CGRectMake(30, 150, wordLabelWidth, 100);
    UILabel *victoryLabel = [[UILabel alloc] initWithFrame:victoryRect];
    victoryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:70];
    victoryLabel.text = @"VICTORY";
    victoryLabel.textColor = [UIColor greenColor];
    self.outcomeLabel = victoryLabel;
    [self.view addSubview:victoryLabel];
}

-(void)drawDefeat
{
    self.textField.enabled = NO;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSUInteger wordLabelWidth = screenRect.size.width;
    CGRect defeatRect = CGRectMake(30, 150, wordLabelWidth, 100);
    UILabel *defeatLabel = [[UILabel alloc] initWithFrame:defeatRect];
    defeatLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:70];
    defeatLabel.text = @"DEFEAT";
    defeatLabel.textColor = [UIColor redColor];
    self.outcomeLabel = defeatLabel;
    [self.view addSubview:defeatLabel];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
