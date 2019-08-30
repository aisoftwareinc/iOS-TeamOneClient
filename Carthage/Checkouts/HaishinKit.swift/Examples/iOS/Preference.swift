struct Preference {
    static var defaultInstance = Preference()

    var uri: String? = "rtmp://ec2-52-86-161-206.compute-1.amazonaws.com/LiveApp/"
    var streamName: String? = "live"
}
