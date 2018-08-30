# post-generate Struct script
# https://github.com/lyptt/struct/wiki/Spec-format:-v2.0#lifecycle-hooks

run do |spec, xcodeproj|

    # https://www.rubydoc.info/github/CocoaPods/Xcodeproj/Xcodeproj/Project
    # https://github.com/CocoaPods/Xcodeproj/blob/master/spec/project/object/native_target_spec.rb
    # https://github.com/CocoaPods/Xcodeproj/blob/c6c1c86459720e5dfbe406eb613a2d2de1607ee2/lib/xcodeproj/constants.rb#L125

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