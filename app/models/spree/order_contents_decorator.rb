module TaxCloud
  module Spree
    module OrderContents
      def tax_cloud_compute_tax
        SpreeTaxCloud::TaxComputer.new(order).compute
      end
    end
  end
end

Spree::OrderContents.prepend ::TaxCloud::Spree::OrderContents
