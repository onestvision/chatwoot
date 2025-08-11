class EnableChatwootV4ForAllAccounts < ActiveRecord::Migration[7.0]
  class MigrationAccount < ApplicationRecord
    self.table_name = 'accounts'
    include FlagShihTzu
    
    # Define feature flags
    FEATURES = {
      31 => :feature_chatwoot_v4  # Assuming chatwoot_v4 is the next available flag
    }.freeze
    
    has_flags FEATURES.merge(column: 'feature_flags', flag_query_mode: :bit_operator, check_for_column: false)
  end

  def up
    # Enable chatwoot_v4 for all accounts in batches of 100
    MigrationAccount.find_in_batches(batch_size: 100) do |accounts|
      accounts.each do |account|
        # Use direct SQL to set the feature flag to avoid any model callbacks/validations
        # that might depend on the new version's code
        feature_flags = account.feature_flags | (1 << 30)  # 2^30 sets the 31st bit
        account.update_columns(feature_flags: feature_flags)
      end
    end
  end

  def down
    # Disable chatwoot_v4 for all accounts
    MigrationAccount.find_in_batches(batch_size: 100) do |accounts|
      accounts.each do |account|
        # Clear the 31st bit (2^30) to disable the feature
        feature_flags = account.feature_flags & ~(1 << 30)
        account.update_columns(feature_flags: feature_flags)
      end
    end
  end
end
