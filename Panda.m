//
//  Panda.m
//  PicSlide
//
//  Created by Mike Cohen on 5/23/10.
//  Copyright 2010 MC Development. All rights reserved.
//

#import "Panda.h"
#import "Picture.h"


@implementation Panda

@synthesize results = _results;
@synthesize done = _done;
@synthesize loading = _loading;
@synthesize parsing = _parsing;

- (id) init
{
    if (self = [super init]) {
        self.results = [NSMutableArray array];
        [self load];
    }
    return self;
}

- (void) dealloc
{
    self.results = nil;
    if (_connection && _loading) {
        [_connection cancel];
        _connection = nil;
    }
    if (_data) {
        [_data release];
        _data = nil;
    }
    [super dealloc];
}

#pragma mark -- INSERT YOUR FLICKR APP KEY HERE --
#define FLICKR_KEY  @"YOUR_FLICKR_API_KEY"

- (void)load
{
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.panda.getPhotos&api_key=%@&panda_name=ling+ling&per_page=5",FLICKR_KEY]]];
    _done = NO;
    if (nil != _data) {
        [_data release];
        _data = nil;
    }
    if (_connection && _loading) {
        [_connection cancel];
        _connection = nil;
    }
    [_results removeAllObjects];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    _loading = (_connection != nil);
    
}

- (int) count
{
    return [_results count];
}

- (id) objectAtIndex: (NSUInteger)index
{
    return [_results objectAtIndex:index];
}

// XML Parser

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _parsing = YES;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    _parsing = NO;
    _done = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PandaFinishedLoading" object:self];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
        attributes:(NSDictionary *)attributeDict 
{
    if ([elementName isEqualToString:@"photo"]) {
        NSString *farm_id = [attributeDict objectForKey:@"farm"];
        NSString *server_id = [attributeDict objectForKey:@"server"];
        NSString *pic_id = [attributeDict objectForKey: @"id"];
        NSString *secret = [attributeDict objectForKey:@"secret"];
        NSString *title = [attributeDict objectForKey:@"title"];
        
        NSString *url = [NSString stringWithFormat: @"http://farm%@.static.flickr.com/%@/%@_%@.jpg",
                         farm_id, server_id, pic_id, secret];
        NSString *thumb = [NSString stringWithFormat: @"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
                         farm_id, server_id, pic_id, secret];

        [_results addObject:[Picture PictureWithFullSize:url thumbnail:thumb title:title]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error 
{
}

// NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == _data) {
        _data = [[NSMutableData alloc] initWithData:data];
    }
    else {
        [_data appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connection = nil;
    [_data release];
    _data = nil;
    _loading = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _connection = nil;
    _loading = NO;
    _parser = [[NSXMLParser alloc] initWithData: _data];
    [_parser setDelegate: self];
    [_parser parse];
    [_parser release];
    _parser = nil;
    [_data release];
    _data = nil;
}

@end
