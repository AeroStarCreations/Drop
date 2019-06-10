local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
    content = {
        width = aspectRatio > 1.5 and 800 or math.floor( 1200 / aspectRatio ),
        height = aspectRatio < 1.5 and 1200 or math.floor( 800 * aspectRatio ),
        scale = "letterBox",
        fps = 60,
        
        imageSuffix = {
            ["@2x"] = 1.3,
            ["@3x"] = 1.95,
        },
    },
    license = {
        google = {
            key = "getKeyFromSomewhere", --TODO: Inside this table, the key value should be set to the corresponding per-app key obtained from the Google Play Developer Console. This key is indicated in the Licensing & In-App Billing section of Services & APIs.
        },
    },}