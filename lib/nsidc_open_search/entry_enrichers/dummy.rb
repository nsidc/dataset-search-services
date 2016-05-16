module NsidcOpenSearch
  module EntryEnrichers
    class Dummy
      def enrich_entry(*)
        # do nothing, this is just a placeholder since we aren't
        # currently doing any enriching
      end
    end
  end
end
