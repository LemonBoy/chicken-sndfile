# chicken-sndfile
:chicken: CHICKEN wrapper for libsndfile

## API

The whole API consists of two functions: `with-sound-from-file` and `with-sound-to-file`.

### with-sound-from-file

`(with-sound-from-file file thunk)` opens the file named by `file` for reading (the format is autodetected) and then executes `thunk` which is a procedure accepting five arguments:

 * _handle_: an opaque pointer to the underlying sndfile object
 * _format_: a three-element list containing the format, the subformat and the endianness of the file
 * _samplerate_: the sample rate of the file
 * _channels_: the number of channels of the file
 * _frames_: the number of audio frames
 
### with-sound-to-file

`(with-sound-to-file file format samplerate channels thunk)` opens the file named by `file` for writing using the specified parameters. Please refer to the previous section for more informations about the format of the parameters. The procedure `thunk` is then executed with a single argument _handle_.

### read-items!/{u8,s8,s16,s32,f32,f64}

`(read-items!/FMT handle buffer [n])` reads `n` items from the open file `handle` in `buffer` and returns the number of items read.
The procedure is safe and it makes sure you're using the right kind of srfi-4 vector and that it is big enough to hold the data.
Note that `n` is optional, by omitting it the library assumes you want to read enough data to fill the whole buffer.

### write-items/{u8,s8,s16,s32,f32,f64}

`(write-items/FMT handle buffer [n])` writes `n` items to the open file `handle` from `buffer` and returns the number of items written.
The procedure is safe and it makes sure you're using the right kind of srfi-4 vector and that holds enough data.
Note that `n` is optional, by omitting it the library assumes you want to write out the whole buffer.
