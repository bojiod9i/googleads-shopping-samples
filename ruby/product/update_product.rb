#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2016, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# Updates the specified product on the specified account.
# This should only be used for properties unsupported by the inventory
# collection. If you're updating any of the supported properties in a product,
# be sure to use the inventory.set method, for performance reasons.

require_relative 'product_common'

def update_product(content_api, merchant_id, product_id)
  # First we need to retrieve the full object, since there are no partial
  # updates for the products collection in Content API v2.
  response = content_api.get_product(merchant_id, product_id) do |res, err|
    if err
      if err.status == 404
        puts "Product #{product_id} not found in account #{merchant_id}."
      else
        handle_errors(err)
      end
      exit
    end
  end

  # Let's fix the warning about product_type and update the product.
  response.product_type = 'English/Classics'

  # Notice that we use insert. The products service does not have an update
  # method. Inserting a product with an ID that already exists means the same
  # as doing an update.
  content_api.insert_product(merchant_id, response) do |res2, err2|
    if err2
      handle_errors(err2)
      exit
    end

    puts 'Product successfully updated.'
    # We shouldn't get the product type warning anymore.
    handle_warnings(res2)
  end
end


if __FILE__ == $0
  unless ARGV.size == 2
    puts "Usage: #{$0} MERCHANT_ID PRODUCT_ID"
    exit
  end
  merchant_id, product_id = ARGV

  content_api = service_setup()
  update_product(content_api, merchant_id, product_id)
end
