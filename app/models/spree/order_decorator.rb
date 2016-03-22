module Spree
  NewOrder = true

  Order.class_eval do
    has_one :tax_cloud_transaction

    self.state_machine.before_transition :to => :delivery, :do => :lookup_tax_cloud, :if => :tax_cloud_eligible?
    self.state_machine.before_transition :to => :payment, :do => :lookup_tax_cloud, :if => :tax_cloud_eligible?
    self.state_machine.after_transition :to => :complete, :do => :capture_and_authorize_tax_cloud, :if => :tax_cloud_eligible?

    def tax_cloud_eligible?
      line_items.present? && ship_address.try(:state_id?)
    end

    def lookup_tax_cloud
      if tax_cloud_transaction.nil?
        create_tax_cloud_transaction
      end
      tax_cloud_compute_tax
    end

    def capture_and_authorize_tax_cloud
      return if additional_tax_total == 0
      transaction = Spree::TaxCloudTransaction.transaction_with_taxcloud(self, NewOrder)
      transaction.authorized_with_capture
    end

    def promotion_adjustment_total
      adjustments.promotion.eligible.sum(:amount).abs
    end

    # Compute  taxcloud, but do not save
    def tax_cloud_compute_tax
      SpreeTaxCloud::TaxComputer.new(self).compute
    end
  end
end
