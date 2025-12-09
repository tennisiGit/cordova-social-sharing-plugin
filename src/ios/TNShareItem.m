#import "TNShareItem.h"

@interface TNShareItem ()
@property(nonatomic, readonly, copy) NSString *combinedText;
@end

@implementation TNShareItem

- (instancetype)initWithText:(NSString *)text
                    urlString:(NSString *)urlString
                 previewImage:(UIImage *)previewImage {
  self = [super init];
  if (self) {
    _text = (text != (id)[NSNull null]) ? text : nil;
    _url = [TNShareItem urlFromString:urlString];
    _previewImage = previewImage;

    if (_text != nil && _url != nil) {
      _combinedText = [NSString stringWithFormat:@"%@\n%@", _text, _url.absoluteString];
    } else if (_text != nil) {
      _combinedText = _text;
    } else if (_url != nil) {
      _combinedText = _url.absoluteString;
    } else {
      _combinedText = @"";
    }
  }
  return self;
}

- (instancetype)init {
  return [self initWithText:nil urlString:nil previewImage:nil];
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
  return self.combinedText != nil ? self.combinedText : @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
        itemForActivityType:(UIActivityType)activityType {
  if (self.text != nil && [self.text length] > 0) {
    return @""; // сам текст будет вторым элементом в activityItems
  }
  if (self.url != nil) {
    return self.url.absoluteString;
  }
  return @"";
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
               subjectForActivityType:(UIActivityType)activityType {
  return self.text;
}

- (LPLinkMetadata *)activityViewControllerLinkMetadata:(UIActivityViewController *)activityViewController
    API_AVAILABLE(ios(13.0)) {
  LPLinkMetadata *metadata = [[LPLinkMetadata alloc] init];
  metadata.title = (self.text != nil && [self.text length] > 0) ? self.text : self.url.absoluteString;

  if (self.url != nil) {
    metadata.originalURL = self.url;
    metadata.URL = self.url;
  }

  if (self.previewImage != nil) {
    NSItemProvider *iconProvider = [[NSItemProvider alloc] initWithObject:self.previewImage];
    metadata.iconProvider = iconProvider;
    metadata.imageProvider = iconProvider;
  }

  return metadata;
}

#pragma mark - Helpers

+ (NSURL *)urlFromString:(NSString *)urlString {
  if (urlString == (id)[NSNull null] || urlString == nil || [urlString length] == 0) {
    return nil;
  }

  NSURL *rawUrl = [NSURL URLWithString:urlString];
  if (rawUrl != nil) {
    return rawUrl;
  }

  NSString *escaped = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
  return [NSURL URLWithString:escaped];
}

@end