//
//  SendRPNumTableViewCell.m
//  Project
//
//  Created by Mike on 2019/3/1.
//  Copyright © 2019 CDJay. All rights reserved.
//

#import "SendRPNumTableViewCell.h"
#import "SendRPCollectionViewCell.h"
#import "SendRPCollectionView.h"

#define kColumn 5
#define kSpacingWidth 4
#define kTableViewImageWidth 20
#define kBtnWidth 65

@interface SendRPNumTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *unitLabel;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *resultDataArray;
@property (nonatomic,strong) SendRPCollectionView *sendRPCollectionView;


@end

@implementation SendRPNumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reusableId:(NSString *)ID
{
    SendRPNumTableViewCell *cell = [[SendRPNumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
    _titleLabel.text = @"红包个数";
    _titleLabel.font = [UIFont systemFontOfSize2:14];
    _titleLabel.textColor = Color_0;
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kTableViewImageWidth+15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    _unitLabel = [UILabel new];
    _unitLabel.text = @"包";
    _unitLabel.font = [UIFont systemFontOfSize2:16];
    _unitLabel.textColor = Color_0;
    [self.contentView addSubview:_unitLabel];
    
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-(kTableViewImageWidth+15));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - kSendRPTitleCellWidth - kBtnWidth - kTableViewImageWidth * 2 - (kColumn + 1) * kSpacingWidth) / kColumn;
    
    CGFloat height = itemWidth * 1 + kSpacingWidth * 2;
    CGFloat frameHeight = (CD_Scal(60, 812) - height) / 2;
    SendRPCollectionView *sendRPCollectionView = [[SendRPCollectionView alloc] initWithFrame:CGRectMake(kTableViewImageWidth+kSendRPTitleCellWidth, frameHeight, [UIScreen mainScreen].bounds.size.width -kSendRPTitleCellWidth - kBtnWidth - kTableViewImageWidth * 2, height)];
//    sendRPCollectionView.backgroundColor = [UIColor redColor];
    sendRPCollectionView.collectionView.allowsMultipleSelection = NO;
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


- (void)setModel:(id)model {
    
    self.resultDataArray = [NSMutableArray arrayWithArray:(NSArray *)model];
    self.sendRPCollectionView.model = self.resultDataArray;
    //    [self.collectionView reloadData];
    //    _titleLabel.text =  [dict objectForKey:@"pokerCount"];
}





- (void)layoutSubviews
{
    [super layoutSubviews];
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end



