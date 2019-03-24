//
//  SendRedPackedCell.m
//  Project
//
//  Created by Mike on 2019/2/28.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "SendRedPackedSelectNumCell.h"
#import "SendRPCollectionViewCell.h"
#import "SendRPCollectionView.h"

#define kColumn 5
#define kSpacingWidth 4
#define kTableViewImageWidth 20
#define kBtnWidth 65

@interface SendRedPackedSelectNumCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *noButton;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *resultDataArray;
@property (nonatomic,strong) SendRPCollectionView *sendRPCollectionView;


@end

@implementation SendRedPackedSelectNumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reusableId:(NSString *)ID
{
    SendRedPackedSelectNumCell *cell = [[SendRedPackedSelectNumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        //        [self initSubviews];
    }
    return self;
}


- (void)setupUI {
    
    self.backgroundColor = [UIColor clearColor];
    _titleLabel = [UILabel new];
    _titleLabel.text = @"雷 号";
    _titleLabel.font = [UIFont systemFontOfSize2:16];
    _titleLabel.textColor = Color_0;
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kTableViewImageWidth+15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    _noButton = [UIButton new];
    _noButton.layer.cornerRadius = (kBtnWidth-15)/2;
    _noButton.layer.masksToBounds = YES;
    _noButton.backgroundColor = [UIColor colorWithRed:0.725 green:0.761 blue:0.843 alpha:1.000];
    [_noButton setTitle:@"不" forState:UIControlStateNormal];
    _noButton.titleLabel.font = [UIFont boldSystemFontOfSize2:30];
    [_noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_noButton addTarget:self action:@selector(onNoButton:) forControlEvents:UIControlEventTouchUpInside];
    _noButton.hidden = YES;
    CGSize size = CGSizeMake(kBtnWidth-15, kBtnWidth-15);
    
//    [_noButton setBackgroundImage: [self createImageWithColor:[UIColor colorWithRed:0.725 green:0.761 blue:0.843 alpha:1.000] size:size]  forState:UIControlStateNormal];
//    [_noButton setBackgroundImage: [self createImageWithColor:[UIColor colorWithRed:0.231 green:0.459 blue:0.796 alpha:1.000] size:size] forState:UIControlStateSelected];
    
    [self.contentView addSubview:_noButton];
    
    [_noButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-(kTableViewImageWidth+10));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kBtnWidth-15, kBtnWidth-15));
    }];
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - kSendRPTitleCellWidth - kBtnWidth - kTableViewImageWidth * 2 - (kColumn + 1) * kSpacingWidth) / kColumn;
    
    CGFloat height = itemWidth * 2 + kSpacingWidth * 3;
    CGFloat frameHeight = (CD_Scal(120, 812) - height) / 2;
    SendRPCollectionView *sendRPCollectionView = [[SendRPCollectionView alloc] initWithFrame:CGRectMake(kTableViewImageWidth+kSendRPTitleCellWidth, frameHeight, [UIScreen mainScreen].bounds.size.width -kSendRPTitleCellWidth - kBtnWidth - kTableViewImageWidth * 2, height)];
    //    sendRPCollectionView.backgroundColor = [UIColor redColor];
    sendRPCollectionView.collectionView.allowsMultipleSelection = YES;
    sendRPCollectionView.tag = 99;
    sendRPCollectionView.selectNumCollectionViewBlock = ^{
        if (self.selectNumBlock) {
            self.selectNumBlock(self.sendRPCollectionView.collectionView.indexPathsForSelectedItems);
        }
    };
    [self addSubview:sendRPCollectionView];
    _sendRPCollectionView = sendRPCollectionView;
    
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithRed:0.945 green:0.945 blue:0.945 alpha:1.000];
    [self.contentView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(kTableViewImageWidth +10);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-(kTableViewImageWidth +10));
        make.height.mas_equalTo(@(1));
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
}

/**
 设置颜色为背景图片
 
 @param color <#color description#>
 @param size <#size description#>
 @return <#return value description#>
 */
- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}



- (void)onNoButton:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        self.noButton.backgroundColor = [UIColor colorWithRed:0.231 green:0.459 blue:0.796 alpha:1.000];
    } else {
        self.noButton.backgroundColor = [UIColor colorWithRed:0.725 green:0.761 blue:0.843 alpha:1.000];
    }

    if (self.selectBtnBlock) {
        self.selectBtnBlock(btn.selected);
    }
}


- (void)setModel:(id)model {
    
    
    self.resultDataArray = [NSMutableArray arrayWithArray:(NSArray *)model];
    self.sendRPCollectionView.model = self.resultDataArray;
    //    [self.collectionView reloadData];
    //    _titleLabel.text =  [dict objectForKey:@"pokerCount"];
    
}

- (void)setIsBtnDisplay:(BOOL)isBtnDisplay {
    self.noButton.hidden = !isBtnDisplay;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setMaxNum:(int)maxNum{
    _maxNum = maxNum;
    _sendRPCollectionView.maxNum = maxNum;
}
@end


