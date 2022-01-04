/**
 * operations.groovy
 *
 * CRUD operations for Multipass virtual machines
 */

import groovy.io.GroovyPrintWriter

static main(args) {
    if (args) {
        "${args.head()}"(*args.tail())
    }
}


/**
 * Create/Launch a Multipass VM.
 *
 * @param name Name of the VM e.g. 'Foo'.
 * @param mem Memory of the VM e.g. '2g'
 * @param cpus Number of CPUs in VM e.g. 2.
 * @param mem Disk Space of the VM e.g. '10G'
 * @param config cloud-init config for the VM in a base64 encoded yaml
 */
def createVm(String name, String mem, String cpus, String disk, String config) {
    byte[] decoded = config.decodeBase64()
    def configYaml = new String(decoded)

    def command = "multipass launch -n " + name + " -m " + mem + " -c " + cpus + " -d " + disk + " --cloud-init -"
    def proc = command.execute()

    proc.withWriter { writer ->
        def gWriter = new GroovyPrintWriter(writer)
        gWriter.println configYaml
    }
    proc.waitForProcessOutput(System.out, System.err)
}


/**
 * Find a Multipass VM.
 *
 * @param name Name of the VM e.g. 'Foo'.
 */
def getVm(String name) {
    def vms = getAllVms()
    def vm = vms.list.find { it.name == name }
    if (vm != null) {
        vm.ip = vm.ipv4[0]
        vm.ipv4 = null
    }
    println(groovy.json.JsonOutput.toJson(deepPrune(vm)))
    return vm
}

/**
 * Find all running instances in Multipass.
 *
 */
def getAllVms() {
    // get running multipass instances
    def command = "multipass list --format=json"
    def proc = command.execute()
    def os = new StringBuffer()
    proc.waitForProcessOutput(os, System.err)

    // parse to json and return
    def jsonSlurper = new groovy.json.JsonSlurper()
    def vms = jsonSlurper.parseText(os.toString())
    return vms;
}

/**
 * Delete a Multipass VM.
 *
 * @param name Name of the VM e.g. 'Foo'.
 */
def deleteVm(String name) {
    def vm = getVm(name)

    def command = "multipass delete " + name + " --purge"
    def proc = command.execute()
    proc.waitForProcessOutput(System.out, System.err)

    if (vm != null) {
        def command2 = "ssh-keygen -R " + vm.ip
        command2.execute()
    }
}


/**
 * Remove nulls from a map.
 *
 * @param map Map.
 */
def deepPrune(Map map) {
    if (map != null) {
        map.collectEntries { k, v -> [k, v instanceof Map ? deepPrune(v) : v] }.findAll { k, v -> v }
    }
}
