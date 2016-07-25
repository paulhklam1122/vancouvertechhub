var OrganizationsDisplay = React.createClass({

  getInitialState: function() {
    return { organizations: this.props.organizations, searchTerm: null, techSizeSearch: null, technologySearch: null };
  },
  getTechValue: function(string){
    var arr = string.split(",");
    var outArr = arr.join("+");
    this.setState({
      technologySearch: outArr
    }, this.filterOrganizations);
  },

  filterOrganizations: function() {
    var termSearch = this.refs.searchInput.value.toLowerCase();
    var techSizeSearch = this.refs.sizeInput.value;
    var url = "search/";
    var that = this;
    $.ajax({
      url: url,
      method: "get",
      dataType: 'json',
      data: {
        term: termSearch,
        size: techSizeSearch,
        tech: this.state.technologySearch
      },
      success: function(data) {
        that.setState({organizations: data})
        this.setState({organizations: data})
      },
      error: function () {
        console.log("Error")
      }
    }.bind(this));

  },
  render: function() {
    var organizations = this.state.organizations.map(function(organization, index) {
      return <Organization organization = { organization }
                           key = { index }
                           searchTerm = { this.state.searchTerm }
                           techSizeSearch = { this.state.techSizeSearch }/>
    }.bind(this));

    return <div>
      <MultiSelectField sendValue={this.getTechValue} techStacks={this.props.techStacks} />
              <input id="organization-search" type="text" className="form-control" placeholder="Search" ref="searchInput" onChange= { this.filterOrganizations } ></input>
              <select id="team-size" className="form-control" ref="sizeInput" onChange= { this.filterOrganizations } >
                <option value="0" defaultValue> Team Size </option>
                <option value="1"> 25 or fewer </option>
                <option value="2"> 26 - 50 </option>
                <option value="3"> more than 50 </option>
              </select>
              <div className="clearfix"></div>
              <div className="container-fluid text-center organization-container">
                <div className="row">
                  { organizations }
                </div>
              </div>
              <br />
          </div>;
  }
});
