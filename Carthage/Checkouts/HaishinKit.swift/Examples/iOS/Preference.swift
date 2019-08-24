struct Preference {
    static var defaultInstance = Preference()

    var uri: String? = "rtmp://ec2-52-15-121-242.us-east-2.compute.amazonaws.com/LiveApp/"
    var streamName: String? = "live"
}
