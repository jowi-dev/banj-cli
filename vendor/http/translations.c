
struct SingleRequest {
  curl_off_t size;        /* -1 if unknown at this point */
  curl_off_t maxdownload; /* in bytes, the maximum amount of data to fetch,
                             -1 means unlimited */
  curl_off_t bytecount;         /* total number of bytes read */
  curl_off_t writebytecount;    /* number of bytes written */

  struct curltime start;         /* transfer started at this time */
  unsigned int headerbytecount;  /* received server headers (not CONNECT
                                    headers) */
  unsigned int allheadercount;   /* all received headers (server + CONNECT) */
  unsigned int deductheadercount; /* this amount of bytes doesn't count when
                                     we check if anything has been transferred
                                     at the end of a connection. We use this
                                     counter to make only a 100 reply (without
                                     a following second response code) result
                                     in a CURLE_GOT_NOTHING error code */
  int headerline;               /* counts header lines to better track the
                                   first one */
  curl_off_t offset;            /* possible resume offset read from the
                                   Content-Range: header */
  int httpversion;              /* Version in response (09, 10, 11, etc.) */
  int httpcode;                 /* error code from the 'HTTP/1.? XXX' or
                                   'RTSP/1.? XXX' line */
  int keepon;
  enum upgrade101 upgr101;      /* 101 upgrade state */

  /* Client Writer stack, handles transfer- and content-encodings, protocol
   * checks, pausing by client callbacks. */
  struct Curl_cwriter *writer_stack;
  /* Client Reader stack, handles transfer- and content-encodings, protocol
   * checks, pausing by client callbacks. */
  struct Curl_creader *reader_stack;
  struct bufq sendbuf; /* data which needs to be send to the server */
  size_t sendbuf_hds_len; /* amount of header bytes in sendbuf */
  time_t timeofdoc;
  long bodywrites;
  char *location;   /* This points to an allocated version of the Location:
                       header data */
  char *newurl;     /* Set to the new URL to use when a redirect or a retry is
                       wanted */

  /* Allocated protocol-specific data. Each protocol handler makes sure this
     points to data it needs. */
  union {
    struct FILEPROTO *file;
    struct FTP *ftp;
    struct HTTP *http;
    struct IMAP *imap;
    struct ldapreqinfo *ldap;
    struct MQTT *mqtt;
    struct POP3 *pop3;
    struct RTSP *rtsp;
    struct smb_request *smb;
    struct SMTP *smtp;
    struct SSHPROTO *ssh;
    struct TELNET *telnet;
  } p;
#ifndef CURL_DISABLE_DOH
  struct dohdata *doh; /* DoH specific data for this request */
#endif
#ifndef CURL_DISABLE_COOKIES
  unsigned char setcookies;
#endif
  BIT(header);        /* incoming data has HTTP header */
  BIT(done);          /* request is done, e.g. no more send/recv should
                       * happen. This can be TRUE before `upload_done` or
                       * `download_done` is TRUE. */
  BIT(content_range); /* set TRUE if Content-Range: was found */
  BIT(download_done); /* set to TRUE when download is complete */
  BIT(eos_written);   /* iff EOS has been written to client */
  BIT(eos_read);      /* iff EOS has been read from the client */
  BIT(rewind_read);   /* iff reader needs rewind at next start */
  BIT(upload_done);   /* set to TRUE when all request data has been sent */
  BIT(upload_aborted); /* set to TRUE when upload was aborted. Will also
                        * show `upload_done` as TRUE. */
  BIT(ignorebody);    /* we read a response-body but we ignore it! */
  BIT(http_bodyless); /* HTTP response status code is between 100 and 199,
                         204 or 304 */
  BIT(chunk);         /* if set, this is a chunked transfer-encoding */
  BIT(ignore_cl);     /* ignore content-length */
  BIT(upload_chunky); /* set TRUE if we are doing chunked transfer-encoding
                         on upload */
  BIT(getheader);    /* TRUE if header parsing is wanted */
  BIT(no_body);      /* the response has no body */
  BIT(authneg);      /* TRUE when the auth phase has started, which means
                        that we are creating a request with an auth header,
                        but it is not the final request in the auth
                        negotiation. */
  BIT(sendbuf_init); /* sendbuf is initialized */
};
