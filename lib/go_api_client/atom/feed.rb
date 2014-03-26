module GoApiClient
  module Atom
    class Feed
      attr_accessor :feed_pages, :entries

      PAGE_FETCH_LIMIT = 2

      def initialize(atom_feed_url, last_entry_id=nil)
        @atom_feed_url = atom_feed_url
        @last_entry_id = last_entry_id
      end

      def fetch!(http_fetcher = HttpFetcher.new)
        self.entries = []
        pages_fetched = 0
        feed_url = @atom_feed_url

        begin
          doc = Nokogiri::XML(http_fetcher.get_response_body(feed_url))
          pages_fetched += 1
          if pages_fetched > PAGE_FETCH_LIMIT
            puts "=" * 80
            puts ""
            puts "[GO WATCHDOG] not fetching past #{PAGE_FETCH_LIMIT} pages of the Go event feed."
            puts "If there is no green build in those pages, Go Watchdog may not work properly.  Get your build green first!"
            puts ""
            puts "=" * 80
            break
          end
          feed_page = GoApiClient::Atom::FeedPage.new(doc.root).parse!

          self.entries += if feed_page.contains_entry?(@last_entry_id)
                            feed_page.entries_after(@last_entry_id)
                          else
                            feed_page.entries
                          end
          feed_url = feed_page.next_page
        end while feed_page.next_page && !feed_page.contains_entry?(@last_entry_id)
        self
      end
    end
  end
end
