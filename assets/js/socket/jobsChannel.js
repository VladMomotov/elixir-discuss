import {debounce} from 'lodash/fp'

export default class JobsChannel {
  constructor(socket) {
    this.socket = socket;
  }

  joinExportToStorage(onStatusChange) {
    onStatusChange = debounce(500, onStatusChange);

    const channel = this.socket.channel('jobs:export_to_storage', {});
    channel.join()
      .receive("error", resp => { console.log("Unable to join jobs:export_to_storage", resp) })
      .receive("ok", ({job_id}) => { 
        onStatusChange("working"); // job becomes `working` before we joins to the status channel

        const jobStatusChannel = this.socket.channel(`jobs:id:${job_id}`);
        jobStatusChannel.join()
          .receive("error", resp => { console.log(`Unable to join jobs:${job_id}`, resp) });

        jobStatusChannel
          .on("status_update", ({status}) => { onStatusChange(status) });
      })
  }
}
