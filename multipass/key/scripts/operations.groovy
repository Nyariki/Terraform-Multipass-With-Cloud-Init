/**
 * operations.groovy
 *
 * CRUD operations for SSH Keys
 */

static main(args) {
    if (args) {
        "${args.head()}"(*args.tail())
    }
}


/**
 * Create/Launch a SSH key.
 *
 * @param name Name of the Key e.g. 'Foo'.
 */
def createKey(String path, String name) {
    def command_create_dir = "mkdir -p " + path
    command_create_dir.execute()

    def command_create_key = ["ssh-keygen", "-m", "PEM", "-t", "rsa", "-b", "4096", "-f", name, "-N", '''''', "-q"]
    def proc_create_key = command_create_key.execute()

    proc_create_key.waitForProcessOutput(System.out, System.err)
}


/**
 * Get Public Key.
 *
 * @param name Name of the SSH public key e.g. 'Foo'.
 */
def getPublicKey(String name) {
    def file = new File(name)
    if (file.exists()) {
        String fileContents = file.text
        def key = [public_key: fileContents]
        println(groovy.json.JsonOutput.toJson(key))
    } else {
        println("{}")
    }
}

/**
 * Delete a SSH Key.
 *
 * @param name Name of the SSH key e.g. 'Foo'.
 */
def deleteKey(String name) {
    def command = "rm ./" + name + " && rm ./" + name + ".pub"
    def proc = command.execute()
    proc.waitForProcessOutput(System.out, System.err)
}