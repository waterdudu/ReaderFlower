//
//  DDGRDBDefines.h
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-21.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#ifndef ReaderFlower_DDGRDBDefines_h
#define ReaderFlower_DDGRDBDefines_h


static NSString* const kTableFeedItemName      = @"";
static NSString* const kDBName      = @"__-__.flower";

typedef enum
{
    DDSubscriptionNone = 0,
    DDSubscriptionFeed = 1,
    DDSubscriptionLabel = 2,
    DDSubscriptionComGoogle = 3

} DDSubscriptionType;


#pragma mark - create table
static NSString *kCreateItemTable = @"CREATE TABLE item ("
//                "id    	INTEGER NOT NULL,"  // sqlite already has a column called ROWID
                "pk             INTEGER PRIMARY KEY,"
//                "content_pk     INTEGER,"
                "itemId         VARCHAR,"         // "id":"tag:google.com,2005:reader/item/cb9acc012b985129"
                "crawlTime      VARCHAR,"
                "title          VARCHAR,"
                "author         VARCHAR,"
               
                "alternate_href    	VARCHAR,"     // "alternate":[{"href":"http://blog.sina.com.cn/s/blog_4701280b0100egc6.html"
                "source_title    	VARCHAR,"     // "i.e hanhan"
                "source_stream_id   VARCHAR,"     // feed/http://blog.sina.com.cn/rss/1191258123.xml
                "published          VARCHAR,"
                "updated            VARCHAR,"

                "short_summary      VARCHAR,"
                   
                "read           BOOLEAN,"
                "starred        BOOLEAN,"
                "liked          BOOLEAN,"
                "shared         BOOLEAN,"
                "like_count    	INTEGER"

//                "broadcaster    	TEXT,"
//                "annotation    	TEXT"
                //    "timestamp    	INTEGER NOT NULL"
                //                                "source_link    	BOOLEAN NOT NULL,"
                //                                "source_post    	BOOLEAN NOT NULL,"

//                                "title_plaintext    	TEXT NOT NULL,"   // why title need a plain text
//            "source_title_plaintext    	TEXT NOT NULL,"     // is this summary ???
")";



static NSString *kCreateContentTable = @"CREATE TABLE content ("
//                "pk             INTEGER,"
                "item_pk        INTEGER,"
                "real_content   VARCHAR"
//                ",images         BLOB"           // saved images for each feed item, NSCache can save all the images

")";


static NSString *kCreateSubscriptionTable = @"CREATE TABLE subscription ("
                                            "pk                INTEGER PRIMARY KEY"
                                            ",subscriptionId    VARCHAR"
                                            ",firstitemmsec     VARCHAR"
                                            ",title             VARCHAR"
                                            ",sortid            VARCHAR"
                                            ",htmlUrl           VARCHAR"
                                            ",categoriesId      BLOB"
                                            ",categoriesLabel   BLOB"

                                            ",unreadcount       INTEGER"
                                            ",continuation      VARCHAR"
                                            ",faviconLink       VARCHAR"
                                            ",favicon           BLOB"

                                            ",stype              INTEGER"
                                            ")"
;




static NSString *kCreateUserTable = @"CREATE TABLE user ("
"pk            INTEGER PRIMARY KEY"
",email         VARCHAR"
",password      VARCHAR"
",userid        VARCHAR"
""
""
""
")"
;


static NSString *kCreateSubscriptionRelationTable = @"CREATE TABLE SubSub ("
"pk                INTEGER"
",subscription_pk  INTEGER"
")";





////////////////////////////////////////////////////////////////////
//        insert sql
////////////////////////////////////////////////////////////////////
#pragma mark - insert sql
static NSString *kInsertUserSQL = @"INSERT INTO User (email, password)"
                                                    "VALUES "
                                                    "(?, ?)"
                                                    ;

static NSString *kInsertItemSQL = @"INSERT INTO item (itemId, crawlTime, title, author," 
                                                        "alternate_href, source_title, source_stream_id, published, updated,"
                                                        "short_summary,"
                                                        "read,starred,liked,shared,like_count"
                                                        ") "
                                                        "VALUES "
                                                        "(?, ?, ?, ?,"
                                                        "?, ?, ?, ?, ?,"
                                                        "?,"
                                                        "?, ?, ?, ?, ?)";

static NSString *kInsertSubscriptionSQL = @"INSERT INTO subscription ("
                                                        "subscriptionId, title, firstitemmsec, sortid, htmlUrl,"
                                                        "categoriesId, categoriesLabel,"
                                                        "unreadcount,continuation,faviconLink"
                                                        ",stype"
                                                        ") "
                                                        "VALUES "
                                                        "( ?, ?, ?, ?, ?"
                                                        ",?, ?"
                                                        ",?, ?, ?"
                                                        ",?"
                                                        ")";


static NSString *kInsertSubSubSQL = @"INSERT INTO SubSub VALUES ("
"(SELECT s.pk from subscription as s WHERE s.subscriptionId = ?),"  // DDSubscriptionGroup's label
"(SELECT s.pk from subscription as s WHERE s.subscriptionId = ?)"   // DDSubscription's subscriptionId
")"
;


static NSString *kInsertContent = @"INSERT INTO Content VALUES ("
"?, "  // item_pk
"?"    // real_content
")"
;

static NSString *kSelectContinuation = @"SELECT continuation from Subscription "
                                        "where subscriptionId = ?"
"";

#pragma mark - select sql
static NSString *kSelectUserByEmail = @"SELECT count(*) from User "
                                                        "WHERE email = ? "
"AND password = ?"
;

static NSString *kSelectSubscriptionWithType = @"SELECT * from subscription "
                                                        "WHERE sType = ?"
                                                        "";

static NSString *kSelectChildSubscriptions = @"SELECT * from "
                                                        "subscription as s, SubSub as ss "
                                                        "WHERE s.pk = ss.subscription_pk "
                                                        "AND ss.pk = ?"
                                                        ""
                                                        ;

static NSString *kSelectSubscriptionsNoLabel = @"SELECT * from "
                                                        "subscription as s, SubSub as ss "
                                                        "WHERE s.pk = ss.subscription_pk "
                                                        "AND ss.pk is NULL"
                                                        ""
                                                        ;

static NSString *kSelectRealContentByItemPK = @"SELECT real_content from content as c, item as i "
"WHERE c.item_pk = i.pk "
"AND i.pk = ?"
;
static NSString *kSelectItemPKByItemId = @"SELECT pk from item where itemid = ?";


// maybe useless, use select * instead, no need to call limit
static NSString *kSelectFeedItemsWithNumber = @"SELECT (content_pk, itemId, crawlTime, title, author,"
                                        "alternate_href, source_title,source_stream_id,"
                                        "pulished,updated,short_summary,"
                                        "read,starred,liked,shared,like_count) "
                                        "from item "
                                        "limit ? ";

//////////////////////////////////////////////////////////////////////////////////////
//                   set table value
//////////////////////////////////////////////////////////////////////////////////////
static NSString *kSetContinuation = @"UPDATE Subscription set continuation = ? "
                                        "where subscriptionId = ?";






















#endif
