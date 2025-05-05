import scrapy
from scrapy.crawler import CrawlerProcess
from scrapy.spiders import SitemapSpider
from scrapy.utils.project import get_project_settings
import re
from pymongo import MongoClient
from scrapy.exceptions import DropItem
import logging

# MongoDB connection
client = MongoClient("mongodb://localhost:27017/")
db = client["MediLink"]
collection = db["Drugs"]

# Define the Item class to structure the scraped data
class DrugItem(scrapy.Item):
    link = scrapy.Field()
    title = scrapy.Field()
    price = scrapy.Field()
    meta = scrapy.Field()
    desc = scrapy.Field()
    detail = scrapy.Field()
    sideEffect = scrapy.Field()

# Create a MongoDB pipeline for storing data
class MongoDBPipeline:
    def process_item(self, item, spider):
        if not all(item.values()):
            raise DropItem("Missing values in item")
        try:
            collection.insert_one(dict(item))
            spider.logger.info(f"Drug item saved to MongoDB: {item['title']}")
            return item
        except Exception as e:
            spider.logger.error(f"MongoDB insertion error: {e}")
            raise DropItem(f"Failed to insert item: {e}")

# Create the spider class for drug data extraction
class DrugSpider(SitemapSpider):
    name = 'drug_spider'
    sitemap_urls = ['https://www.1mg.com/sitemap.xml']
    sitemap_follow = [r'sitemap']
    sitemap_rules = [
        (r'/drugs/', 'parse_drug'),
        (r'/otc/', 'parse_drug'),
    ]

    def parse_drug(self, response):
        self.logger.info(f"Processing drug page: {response.url}")
        try:
            item = DrugItem()
            item['link'] = response.url
            
            # Extract data using CSS selectors
            item['title'] = response.css('.DrugHeader__title-content___2ZaPo::text').get('').strip()
            item['price'] = response.css('.DrugPriceBox__price___dj2lv::text').get('').strip()
            item['meta'] = response.css('.DrugHeader__meta-value___vqYM0::text').get('').strip()
            item['desc'] = response.css('.DrugOverview__content___22ZBX::text').get('').strip()
            item['detail'] = response.css('.DrugPriceBox__quantity___2LGBX::text').get('').strip()
            item['sideEffect'] = response.css('.DrugOverview__container___CqA8x::text').get('').strip()
            
            # Fallbacks using more generic selectors if specific classes aren't found
            if not item['title']:
                item['title'] = response.css('h1::text').get('').strip()
            if not item['desc'] and response.css('div.DrugOverview__content___22ZBX'):
                item['desc'] = ' '.join(response.css('div.DrugOverview__content___22ZBX ::text').getall()).strip()
            if not item['sideEffect'] and response.css('div.DrugOverview__container___CqA8x'):
                item['sideEffect'] = ' '.join(response.css('div.DrugOverview__container___CqA8x ::text').getall()).strip()
            
            return item
            
        except Exception as e:
            self.logger.error(f"Error parsing {response.url}: {e}")
            return None

# Configure Scrapy settings
def get_settings():
    settings = {
        'BOT_NAME': 'MediLink',
        'ROBOTSTXT_OBEY': True,
        'CONCURRENT_REQUESTS': 32,  # Adjust based on your system capacity
        'DOWNLOAD_DELAY': 0.25,     # Adjust to avoid overloading the site
        'ITEM_PIPELINES': {
            '__main__.MongoDBPipeline': 300,
        },
        'LOG_LEVEL': 'INFO',
        'RETRY_TIMES': 3,
        'HTTPCACHE_ENABLED': True,
        'USER_AGENT': 'MediLink Drug Information Spider (+http://www.yourdomain.com)',
    }
    return settings

def run_spider():
    settings = get_settings()
    process = CrawlerProcess(settings)
    process.crawl(DrugSpider)
    process.start()  # The script will block here until the crawling is finished

if __name__ == "__main__":
    try:
        run_spider()
        print("Crawling completed")
    except KeyboardInterrupt:
        print("Crawling interrupted by user")
    finally:
        print("Cleaning up resources...")
        client.close()