pub fn ignore(err:anyerror , err_to_ignore:anyerror) !void {
    if (err == err_to_ignore)  { return; }
    else return err;
}