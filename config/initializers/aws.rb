aws = YAML.load(ERB.new(File.read("#{Rails.root}/config/aws.yml")).result)[Rails.env].symbolize_keys
AWS.config(access_key_id: aws[:access_key_id],
secret_access_key: aws[:secret_access_key])

S3_BUCKET = AWS::S3.new.buckets['diyavatar']
