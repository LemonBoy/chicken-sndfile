(module sndfile
  (with-sound-from-file with-sound-to-file 
   read-items!/u8  read-items!/s8
   read-items!/s16 read-items!/s32
   read-items!/f32 read-items!/f64
   write-items/u8  write-items/s8
   write-items/s16 write-items/s32
   write-items/f32 write-items/f64)
  (import scheme chicken foreign)

(use foreigners srfi-4)

(foreign-declare "#include <sndfile.h>")

(define-foreign-record-type (sf-info "SF_INFO")
  (constructor: %make-sf-info)
  (destructor:  %free-sf-info)
  (integer64 frames     sf-info-frames)
  (int       samplerate sf-info-samplerate set-sf-info-samplerate!)
  (int       channels   sf-info-channels   set-sf-info-channels!)
  (int       format     sf-info-format     set-sf-info-format!)
  (int       sections   sf-info-sections)
  (bool      seekable   sf-info-seekable))

(define-foreign-enum-type (sf-format int)
  (sf-format->int int->sf-format)
  ((wav)   SF_FORMAT_WAV)
  ((aiff)  SF_FORMAT_AIFF)
  ((au)    SF_FORMAT_AU)
  ((raw)   SF_FORMAT_RAW)
  ((paf)   SF_FORMAT_PAF)
  ((svx)   SF_FORMAT_SVX)
  ((nist)  SF_FORMAT_NIST)
  ((voc)   SF_FORMAT_VOC)
  ((ircam) SF_FORMAT_IRCAM)
  ((w64)   SF_FORMAT_W64)
  ((mat4)  SF_FORMAT_MAT4)
  ((mat5)  SF_FORMAT_MAT5)
  ((pvf)   SF_FORMAT_PVF)
  ((xi)    SF_FORMAT_XI)
  ((htk)   SF_FORMAT_HTK)
  ((sds)   SF_FORMAT_SDS)
  ((avr)   SF_FORMAT_AVR)
  ((wavex) SF_FORMAT_WAVEX)
  ((sd2)   SF_FORMAT_SD2)
  ((flac)  SF_FORMAT_FLAC)
  ((caf)   SF_FORMAT_CAF)
  ((wve)   SF_FORMAT_WVE)
  ((ogg)   SF_FORMAT_OGG)
  ((mpc2k) SF_FORMAT_MPC2K)
  ((rf64)  SF_FORMAT_RF64))

(define-foreign-enum-type (sf-subformat int)
  (sf-subformat->int int->sf-subformat)
  ((pcm-s8)    SF_FORMAT_PCM_S8)
  ((pcm-16)    SF_FORMAT_PCM_16)
  ((pcm-24)    SF_FORMAT_PCM_24)
  ((pcm-32)    SF_FORMAT_PCM_32)
  ((pcm-u8)    SF_FORMAT_PCM_U8)
  ((float)     SF_FORMAT_FLOAT)
  ((double)    SF_FORMAT_DOUBLE)
  ((ulaw)      SF_FORMAT_ULAW)
  ((alaw)      SF_FORMAT_ALAW)
  ((ima-adpcm) SF_FORMAT_IMA_ADPCM)
  ((ms-adpcm)  SF_FORMAT_MS_ADPCM)
  ((gsm610)    SF_FORMAT_GSM610)
  ((vox-adpcm) SF_FORMAT_VOX_ADPCM)
  ((g721-32)   SF_FORMAT_G721_32)
  ((g723-24)   SF_FORMAT_G723_24)
  ((g723-40)   SF_FORMAT_G723_40)
  ((dwvw-12)   SF_FORMAT_DWVW_12)
  ((dwvw-16)   SF_FORMAT_DWVW_16)
  ((dwvw-24)   SF_FORMAT_DWVW_24)
  ((dwvw-n)    SF_FORMAT_DWVW_N)
  ((dpcm-8)    SF_FORMAT_DPCM_8)
  ((dpcm-16)   SF_FORMAT_DPCM_16)
  ((vorbis)    SF_FORMAT_VORBIS)
  ((alac-16)   SF_FORMAT_ALAC_16)
  ((alac-20)   SF_FORMAT_ALAC_20)
  ((alac-24)   SF_FORMAT_ALAC_24)
  ((alac-32)   SF_FORMAT_ALAC_32))

(define-foreign-enum-type (sf-endian int)
  (sf-endian->int int->sf-endian)
  ((file)   SF_ENDIAN_FILE)
  ((little) SF_ENDIAN_LITTLE)
  ((big)    SF_ENDIAN_BIG)
  ((cpu)    SF_ENDIAN_CPU))

(define-foreign-variable sfm-read  int "SFM_READ")
(define-foreign-variable sfm-write int "SFM_WRITE")

(define-foreign-variable sf-format-submask  int "SF_FORMAT_SUBMASK")
(define-foreign-variable sf-format-typemask int "SF_FORMAT_TYPEMASK")
(define-foreign-variable sf-format-endmask  int "SF_FORMAT_ENDMASK")

(define c-sf-open
  (foreign-lambda c-pointer sf_open c-string int c-pointer))
(define c-sf-seek
  (foreign-lambda integer64 sf_seek c-pointer integer64 int))
(define c-sf-close
  (foreign-lambda int sf_close c-pointer))
(define c-sf-error
  (foreign-lambda int sf_error c-pointer))
(define c-sf-strerror
  (foreign-lambda c-string sf_strerror c-pointer))
(define c-sf-error
  (foreign-lambda int sf_error c-pointer))

(define c-sf-read-short
  (foreign-lambda integer64 sf_read_short c-pointer s16vector integer64))
(define c-sf-read-int
  (foreign-lambda integer64 sf_read_int c-pointer s32vector integer64))
(define c-sf-read-float
  (foreign-lambda integer64 sf_read_float c-pointer f32vector integer64))
(define c-sf-read-double
  (foreign-lambda integer64 sf_read_double c-pointer f64vector integer64))
(define c-sf-read-char
  (foreign-lambda integer64 sf_read_raw c-pointer s8vector integer64))
(define c-sf-read-byte
  (foreign-lambda integer64 sf_read_raw c-pointer u8vector integer64))

(define c-sf-write-short
  (foreign-lambda integer64 sf_write_short c-pointer s16vector integer64))
(define c-sf-write-int
  (foreign-lambda integer64 sf_write_int c-pointer s32vector integer64))
(define c-sf-write-float
  (foreign-lambda integer64 sf_write_float c-pointer f32vector integer64))
(define c-sf-write-double
  (foreign-lambda integer64 sf_write_double c-pointer f64vector integer64))
(define c-sf-write-char
  (foreign-lambda integer64 sf_write_raw c-pointer s8vector integer64))
(define c-sf-write-byte
  (foreign-lambda integer64 sf_write_raw c-pointer u8vector integer64))

(define (format->triple fmt)
  (list (int->sf-format    (bitwise-and fmt sf-format-typemask))
	(int->sf-subformat (bitwise-and fmt sf-format-submask))
	(int->sf-endian    (bitwise-and fmt sf-format-endmask))))

(define (triple->format tri)
  (bitwise-ior
    (sf-format->int    (car tri))
    (sf-subformat->int (cadr tri))
    (sf-endian->int    (caddr tri))))

(define (with-sound-from-file file thunk)
  (##sys#check-string file 'with-sound-from-file)
  (let* ((info (%make-sf-info))
	 (handle (c-sf-open file sfm-read info)))
    (unless handle
      (error "could not open the file" file (c-sf-strerror #f)))
    (thunk handle
	   (format->triple (sf-info-format info))
	   (sf-info-samplerate info)
	   (sf-info-channels info)
	   (sf-info-frames info))
    (%free-sf-info info)
    (c-sf-close handle)))

(define (with-sound-to-file file format samplerate channels thunk)
  (##sys#check-string file 'with-sound-to-file)
  (##sys#check-list format 'with-sound-to-file)
  (##sys#check-exact samplerate 'with-sound-to-file)
  (##sys#check-exact channels 'with-sound-to-file)
  (let* ((info (%make-sf-info))
	 (_ (set-sf-info-format! info (triple->format format)))
	 (_ (set-sf-info-samplerate! info samplerate))
	 (_ (set-sf-info-channels! info channels))
	 (handle (c-sf-open file sfm-write info)))
    (unless handle
      (error "could not open the file" file (c-sf-strerror #f)))
    (thunk handle)
    (%free-sf-info info)
    (c-sf-close handle)))

(define-syntax define-rw-function
  (er-macro-transformer
    (lambda (x r c)
      (let ((name (strip-syntax (cadr x)))
	    (cfun (strip-syntax (caddr x)))
	    (vfun (strip-syntax (cadddr x))))
	`(define ,name
	   (lambda (file buf #!optional n)
	     (let ((buf-len (,vfun buf)))
	       (when (and n (fx< buf-len n))
		 (error "buffer is too small"))
	       (let ((read (,cfun file buf (or n buf-len))))
		 ; throw an error if something went wrong
		 (when (and (fx= read 0) (fx> (c-sf-error file) 0))
		   (error (c-sf-strerror file)))
		 read))))))))

(define-rw-function read-items!/s8  c-sf-read-char   s8vector-length)
(define-rw-function read-items!/u8  c-sf-read-byte   u8vector-length)
(define-rw-function read-items!/s16 c-sf-read-short  s16vector-length)
(define-rw-function read-items!/s32 c-sf-read-int    s32vector-length)
(define-rw-function read-items!/f32 c-sf-read-float  f32vector-length)
(define-rw-function read-items!/f64 c-sf-read-double f64vector-length)

(define-rw-function write-items/s8  c-sf-write-char   s8vector-length)
(define-rw-function write-items/u8  c-sf-write-byte   u8vector-length)
(define-rw-function write-items/s16 c-sf-write-short  s16vector-length)
(define-rw-function write-items/s32 c-sf-write-int    s32vector-length)
(define-rw-function write-items/f32 c-sf-write-float  f32vector-length)
(define-rw-function write-items/f64 c-sf-write-double f64vector-length)
)
