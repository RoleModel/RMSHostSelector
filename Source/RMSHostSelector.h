//
//  RMSHostSelector.h
//  FarrierSupply
//
//  Created by Tony Ingraldi on 10/11/13.
//
//

#import <UIKit/UIKit.h>

typedef void (^RMSHostSelectCompletionBlock)(NSString *selectedHost);


@interface RMSHostSelector : UITableViewController

- (void)selectHostWithBlock:(RMSHostSelectCompletionBlock)completionBlock;

@end
