# post-generate Struct script
# https://github.com/lyptt/struct/wiki/Spec-format:-v2.0#lifecycle-hooks

run do |spec, xcodeproj|

    # https://www.rubydoc.info/github/CocoaPods/Xcodeproj/Xcodeproj/Project
    # https://github.com/CocoaPods/Xcodeproj/blob/master/spec/project/object/native_target_spec.rb

    xcodeproj
        .targets
        .select{ |t| ["com.apple.product-type.framework"].include?(t.product_type) }
        .each{ |t|

            t.build_configurations.each do |config|

                config.build_settings['PRODUCT_NAME'] = '$(inherited)'
            end
        }

    xcodeproj.save()

end