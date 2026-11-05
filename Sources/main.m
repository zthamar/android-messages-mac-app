// Messages for Android — a thin native Mac wrapper around Google Messages
// for web. Written in Objective-C so it builds with plain clang from the
// Xcode Command Line Tools (no Swift toolchain needed).
//
// Your phone does the actual sending/receiving; this window just shows
// the same Messages web page, paired once with a QR code.
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate>
@property (strong) NSWindow *window;
@property (strong) WKWebView *webView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSRect frame = NSMakeRect(0, 0, 1000, 700);
    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:frame
                  styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                             NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];
    window.title = @"Messages";
    [window center];
    self.window = window;

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // Default data store = cookies and local storage persist between
    // launches, which is what keeps the Google Messages pairing.
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    config.applicationNameForUserAgent = @"AndroidMessagesMac/1.0";

    WKWebView *webView = [[WKWebView alloc] initWithFrame:window.contentView.bounds
                                             configuration:config];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [window.contentView addSubview:webView];
    self.webView = webView;
    [webView loadRequest:[NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://messages.google.com/web"]]];

    // Menu bar: Messages > Reload (Cmd+R), Quit (Cmd+Q).
    NSMenu *mainMenu = [[NSMenu alloc] init];
    NSMenuItem *appItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Messages"];
    NSMenuItem *reloadItem = [[NSMenuItem alloc] initWithTitle:@"Reload"
                                                          action:@selector(reloadWebView:)
                                                   keyEquivalent:@"r"];
    reloadItem.target = self;
    [appMenu addItem:reloadItem];
    [appMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Messages"
                                                       action:@selector(terminate:)
                                                keyEquivalent:@"q"];
    quitItem.target = NSApp;
    [appMenu addItem:quitItem];
    appItem.submenu = appMenu;
    [mainMenu addItem:appItem];
    [NSApp setMainMenu:mainMenu];

    [window makeKeyAndOrderFront:nil];
}

- (void)reloadWebView:(id)sender {
    [self.webView reload];
}

// Links that try to open a new window (target=_blank) open in the
// user's default browser instead of a blank window.
- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
    [[NSWorkspace sharedWorkspace] openURL:navigationAction.request.URL];
    return nil;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
