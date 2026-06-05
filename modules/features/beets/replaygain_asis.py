from beets.importer.tasks import Action
from beets.plugins import BeetsPlugin
from beets.util import syspath
from mediafile import MediaFile, UnreadableFileError

REPLAYGAIN_FIELDS = (
    "rg_track_gain",
    "rg_track_peak",
    "rg_album_gain",
    "rg_album_peak",
    "r128_track_gain",
    "r128_album_gain",
)


class ReplayGainAsIsPlugin(BeetsPlugin):
    def __init__(self):
        super().__init__()
        self.register_listener("import_task_files", self.import_task_files)

    def import_task_files(self, session, task):
        if task.choice_flag != Action.ASIS:
            return

        for item in task.imported_items():
            self.write_replaygain_tags(item)

    def write_replaygain_tags(self, item):
        tags = {
            field: item.get(field)
            for field in REPLAYGAIN_FIELDS
            if item.get(field) is not None
        }
        if not tags:
            return

        try:
            mediafile = MediaFile(syspath(item.path))
            mediafile.update(tags)
            mediafile.save()
        except UnreadableFileError as exc:
            self._log.error("could not write ReplayGain tags to {}: {}", item, exc)
            return

        item.mtime = item.current_mtime()
        item.store()
        self._log.info("wrote ReplayGain tags to {}", item)
