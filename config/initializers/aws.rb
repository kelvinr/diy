creds = Rails.env == "production" ? {access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]} :
JSON.load(File.read("/home/kelvin/creds/diy_creds.json")).symbolize_keys

Aws.config.update({region: "us-east-1",
  credentials: Aws::Credentials.new(creds[:access_key_id], creds[:secret_access_key]),
  })

S3_BUCKET = Aws::S3::Resource.new.bucket('diyavatar')
