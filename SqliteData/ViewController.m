//
//  ViewController.m
//  SqliteData
//
//  Created by zhanglongtao on 16/12/9.
//  Copyright © 2016年 hanju001. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "ShopModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nametextFile;
@property (weak, nonatomic) IBOutlet UITextField *priceTextFiled;
- (IBAction)clickButtoon:(id)sender;
@property(nonatomic,assign) sqlite3 *db;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *shops;

@end

@implementation ViewController
- (NSMutableArray *)shops{
    if (!_shops)
    {
        _shops = [NSMutableArray array];
    }
    return _shops;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSArray *data = @[@"fdsfs",@"fdsfds"];
//    
//    [data writeToFile:@"/User/apple/Desktop/name.plst" atomically:YES];
    
    //数据库
    
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
//    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
//       
//        NSLog(@"A");
//    });
//    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
//       
//        NSLog(@"B");
//        
//    });
//    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
//       
//        NSLog(@"C");
//        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"D");
//        });
//        NSLog(@"E");
//    });
//    dispatch_async(queue, ^{
//       
//        NSLog(@"F");
//    });
//    dispatch_async(queue, ^{
//        NSLog(@"G");
//    });
    
//    NSMutableString *sql = [NSMutableString string];
//    for (int i = 0;i < 1000;i++)
//    {
//        NSString *name = [NSString stringWithFormat:@"inphone%d",i];
//        double price = arc4random()%10000+100;
//        int left_count=arc4random()%1000;
//        [sql appendFormat:@"insert into t_HJServer(name,price,left_count)values('%@',%f,%d);\n",name,price,left_count];
//    }
//    
//    [sql writeToFile:@"/Users/hanju001/Desktop/shop.sql" atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"\n%@",sql);
    
    
    UISearchBar *bar = [[UISearchBar alloc]init];
    bar.frame = CGRectMake(0, 0, 320, 44);
    bar.delegate = self;
    self.tableView.tableHeaderView = bar;
    
    //打开数据库（连接数据库）
    NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"shops.sqlite"];
    //如果文件不存在 就会创建
    //数据库实例
    int status = sqlite3_open(fileName.UTF8String, &_db);
    if (status == SQLITE_OK)
    {
        NSLog(@"打开数据库成功");
        
        const char *sql = "CREATE TABLE IF NOT EXISTS t_shop (id integer PRIMARY KEY,name text NOT NULL,price real)";
        char *errmsg;
        sqlite3_exec(self.db,sql, NULL, NULL, &errmsg);
        if (errmsg)
        {
            NSLog(@"创建表失败%s",errmsg);
        }
        
    }
    else
    {
        NSLog(@"打开失败");
    }
    
    
    //获得数据库数组
    [self findDataFromSqlite];
    
    
}

- (void)findDataFromSqlite
{
    const char *sql = "SELECT name,price FROM t_shop";
    //用来却结果的
    sqlite3_stmt *smt = NULL;
    //准备
    int status = sqlite3_prepare_v2(self.db, sql, -1, &smt, NULL);
    if (status == SQLITE_OK)
    {
        
        while(sqlite3_step(smt) == SQLITE_ROW)//取一行数据
        {
            const  char *name = (const char *)sqlite3_column_text(smt, 0);
            const  char *price = (const char *)sqlite3_column_text(smt, 1);
            
            ShopModel *model = [ShopModel new];
            model.name = [NSString stringWithFormat:@"%s",name];
            model.price = [NSString stringWithUTF8String:price];
            
            [self.shops addObject:model];
        }
    }
    else
    {
        NSLog(@"获取数据失败");
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickButtoon:(id)sender {
    
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_shop(name,price) VALUES('%@',%f)",self.nametextFile.text,self.priceTextFiled.text.doubleValue];
    char *errmsg;
    sqlite3_exec(self.db, sql.UTF8String, NULL, NULL, &errmsg);
    
    
    if(errmsg)
    {
        NSLog(@"写入失败%s",errmsg);
    }
    else
    {
        ShopModel *model = [ShopModel new];
        model.name = [NSString stringWithFormat:@"%@",self.nametextFile.text];
        model.price = [NSString stringWithFormat:@"%@",self.priceTextFiled.text];
        
        [self.shops addObject:model];
        
        [self.tableView reloadData];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shops.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"shop";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    ShopModel *model = self.shops[indexPath.row];
    
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.price;
    return cell;


}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    [self.shops removeAllObjects];
//    NSString *sql = [NSString stringWithFormat:@"SELECT name,price FROM t_shop WHERE name ='%@'",searchText];//精确查询
    NSString *sql = [NSString stringWithFormat:@"SELECT name,price FROM t_shop WHERE name LIKE '%%%@%%';",searchText];//模糊查询
    //用来却结果的
    sqlite3_stmt *smt = NULL;
    //准备
    int status = sqlite3_prepare_v2(self.db, sql.UTF8String, -1, &smt, NULL);
    if (status == SQLITE_OK)
    {
        
        while(sqlite3_step(smt) == SQLITE_ROW)//取一行数据
        {
            const  char *name = (const char *)sqlite3_column_text(smt, 0);
            const  char *price = (const char *)sqlite3_column_text(smt, 1);
            
            ShopModel *model = [ShopModel new];
            model.name = [NSString stringWithFormat:@"%s",name];
            model.price = [NSString stringWithUTF8String:price];
            
            [self.shops addObject:model];
        }
    }
    else
    {
        NSLog(@"获取数据失败");
    }
    
    [self.tableView reloadData];
}
@end
