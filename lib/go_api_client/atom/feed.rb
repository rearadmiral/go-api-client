module GoApiClient
  module Atom
    class Feed
      attr_accessor :feed_pages, :entries

      def initialize(atom_feed_url, last_entry_id=nil, page_fetch_limit=nil)
        @atom_feed_url = atom_feed_url
        @last_entry_id = last_entry_id
        @page_fetch_limit = page_fetch_limit.to_i
      end

      def fetch!(http_fetcher = HttpFetcher.new)
        self.entries = []
        pages_fetched = 0
        feed_url = @atom_feed_url

        begin
          doc = Nokogiri::XML(http_fetcher.get_response_body(feed_url))
          pages_fetched += 1
          if @page_fetch_limit > 0 && pages_fetched > @page_fetch_limit
            puts "=" * 100
            puts ""
            puts "[GoApiClient] not fetching past #{@page_fetch_limit} pages of the Go.CD event feed."
            puts "If there is no green build in those pages, your app may not work properly."
            puts "Get your build green first!"
            puts ""
            puts "=" * 100
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
